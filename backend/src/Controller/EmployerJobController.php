<?php

namespace App\Controller;

use App\Entity\JobPost;
use App\Entity\JobTask;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

final class EmployerJobController extends AbstractController
{
    private function verifyEmployer(Request $request, JWTEncoderInterface $jwtEncoder): array|JsonResponse
    {
        $token = $request->headers->get('X-Auth-Token');

        if (!$token) {
            return $this->json(['message' => 'Missing authentication token.'], 401);
        }

        try {
            $decodedToken = $jwtEncoder->decode($token);
        } catch (\Throwable $e) {
            return $this->json(['message' => 'Invalid authentication token.'], 401);
        }

        $roles = $decodedToken['roles'] ?? [];

        if (!in_array('ROLE_EMPLOYER', $roles, true) && !in_array('ROLE_SUPER_ADMIN', $roles, true)) {
            return $this->json(['message' => 'Access denied. Employer role required.'], 403);
        }

        return $decodedToken;
    }

    private function getEmployerFromToken(array $decodedToken, EntityManagerInterface $entityManager): ?User
    {
        $userRepository = $entityManager->getRepository(User::class);

        $possibleValues = [
            $decodedToken['sub'] ?? null,
            $decodedToken['username'] ?? null,
            $decodedToken['email'] ?? null,
            $decodedToken['user_identifier'] ?? null,
            $decodedToken['id'] ?? null,
        ];

        foreach ($possibleValues as $value) {
            if (!$value) continue;

            if (is_numeric($value)) {
                $user = $userRepository->find((int) $value);
                if ($user instanceof User) return $user;
            }

            $user = $userRepository->findOneBy(['email' => (string) $value]);
            if ($user instanceof User) return $user;

            $user = $userRepository->findOneBy(['username' => (string) $value]);
            if ($user instanceof User) return $user;
        }

        $users = $userRepository->findAll();

        foreach ($users as $user) {
            if ($user instanceof User && in_array('ROLE_EMPLOYER', $user->getRoles(), true)) {
                return $user;
            }
        }

        return null;
    }

    private function formatJob(JobPost $job): array
    {
        $tasks = [];

        foreach ($job->getTasks() as $task) {
            $tasks[] = [
                'id' => $task->getId(),
                'taskName' => $task->getTaskName(),
                'description' => $task->getDescription(),
                'feasibilityLevel' => $task->getFeasibilityLevel(),
                'requiredAbilities' => $task->getRequiredAbilities(),
            ];
        }

        $employerProfile = $job->getEmployer()?->getEmployerProfile();

        return [
            'id' => $job->getId(),
            'title' => $job->getTitle(),
            'companyName' => $job->getCompanyName(),
            'companyLogoUrl' => $employerProfile?->getLogoUrl(),
            'employerProfile' => $employerProfile ? [
                'companyName' => $employerProfile->getCompanyName(),
                'industry' => $employerProfile->getIndustry(),
                'location' => $employerProfile->getLocation(),
                'website' => $employerProfile->getWebsite(),
                'logoUrl' => $employerProfile->getLogoUrl(),
                'description' => $employerProfile->getDescription(),
                'accessibilityStatement' => $employerProfile->getAccessibilityStatement(),
            ] : null,
            'location' => $job->getLocation(),
            'jobType' => $job->getJobType(),
            'workMode' => $job->getWorkMode(),
            'category' => $job->getCategory(),
            'description' => $job->getDescription(),
            'requirements' => $job->getRequirements(),
            'applicationDeadline' => $job->getApplicationDeadline()?->format('Y-m-d'),
            'cvRequired' => $job->isCvRequired(),
            'coverLetterRequired' => $job->isCoverLetterRequired(),
            'status' => $job->getStatus(),
            'createdAt' => $job->getCreatedAt()?->format('Y-m-d H:i:s'),
            'updatedAt' => $job->getUpdatedAt()?->format('Y-m-d H:i:s'),
            'tasks' => $tasks,
        ];
    }

    #[Route('/api/employer/jobs', name: 'api_employer_jobs_create', methods: ['POST'])]
    public function createJob(
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $employerCheck = $this->verifyEmployer($request, $jwtEncoder);

        if ($employerCheck instanceof JsonResponse) {
            return $employerCheck;
        }

        $employer = $this->getEmployerFromToken($employerCheck, $entityManager);

        if (!$employer) {
            return $this->json(['message' => 'Employer user not found.'], 404);
        }

        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json(['message' => 'Invalid request body.'], 400);
        }

        $requiredFields = [
            'title',
            'companyName',
            'location',
            'jobType',
            'workMode',
            'category',
            'description',
            'applicationDeadline',
        ];

        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || trim((string) $data[$field]) === '') {
                return $this->json(['message' => $field . ' is required.'], 400);
            }
        }

        try {
            $deadline = new \DateTimeImmutable($data['applicationDeadline']);
        } catch (\Throwable $e) {
            return $this->json(['message' => 'Invalid application deadline.'], 400);
        }

        $job = new JobPost();
        $job->setEmployer($employer);
        $job->setTitle(trim($data['title']));
        $job->setCompanyName(trim($data['companyName']));
        $job->setLocation(trim($data['location']));
        $job->setJobType(trim($data['jobType']));
        $job->setWorkMode(trim($data['workMode']));
        $job->setCategory(trim($data['category']));
        $job->setDescription(trim($data['description']));
        $job->setRequirements(isset($data['requirements']) ? trim((string) $data['requirements']) : null);
        $job->setApplicationDeadline($deadline);
        $job->setCvRequired((bool) ($data['cvRequired'] ?? true));
        $job->setCoverLetterRequired((bool) ($data['coverLetterRequired'] ?? false));
        $job->setStatus('published');
        $job->setUpdatedAt(new \DateTimeImmutable());

        $tasksData = $data['tasks'] ?? [];

        if (is_array($tasksData)) {
            foreach ($tasksData as $taskData) {
                if (!is_array($taskData)) continue;

                $taskName = trim((string) ($taskData['taskName'] ?? ''));

                if ($taskName === '') continue;

                $task = new JobTask();
                $task->setTaskName($taskName);
                $task->setDescription(isset($taskData['description']) ? trim((string) $taskData['description']) : null);
                $task->setFeasibilityLevel(trim((string) ($taskData['feasibilityLevel'] ?? 'not_calculated')));
                $task->setRequiredAbilities(
                    is_array($taskData['requiredAbilities'] ?? null)
                        ? $taskData['requiredAbilities']
                        : []
                );

                $job->addTask($task);
            }
        }

        $entityManager->persist($job);
        $entityManager->flush();

        return $this->json([
            'message' => 'Job posted successfully.',
            'job' => $this->formatJob($job),
        ], 201);
    }

    #[Route('/api/employer/jobs', name: 'api_employer_jobs_list', methods: ['GET'])]
    public function listMyJobs(
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $employerCheck = $this->verifyEmployer($request, $jwtEncoder);

        if ($employerCheck instanceof JsonResponse) {
            return $employerCheck;
        }

        $employer = $this->getEmployerFromToken($employerCheck, $entityManager);

        if (!$employer) {
            return $this->json(['message' => 'Employer user not found.'], 404);
        }

        $jobs = $entityManager
            ->getRepository(JobPost::class)
            ->findBy(['employer' => $employer], ['id' => 'DESC']);

        return $this->json([
            'jobs' => array_map(fn (JobPost $job) => $this->formatJob($job), $jobs),
        ]);
    }

    #[Route('/api/employer/jobs/{id}', name: 'api_employer_jobs_update', methods: ['PUT'])]
    public function updateJob(
        int $id,
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $employerCheck = $this->verifyEmployer($request, $jwtEncoder);

        if ($employerCheck instanceof JsonResponse) {
            return $employerCheck;
        }

        $employer = $this->getEmployerFromToken($employerCheck, $entityManager);

        if (!$employer) {
            return $this->json(['message' => 'Employer user not found.'], 404);
        }

        $job = $entityManager->getRepository(JobPost::class)->find($id);

        if (!$job) {
            return $this->json(['message' => 'Job not found.'], 404);
        }

        if ($job->getEmployer()?->getId() !== $employer->getId() && !in_array('ROLE_SUPER_ADMIN', $employer->getRoles(), true)) {
            return $this->json(['message' => 'You cannot edit this job.'], 403);
        }

        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json(['message' => 'Invalid request body.'], 400);
        }

        $requiredFields = [
            'title',
            'companyName',
            'location',
            'jobType',
            'workMode',
            'category',
            'description',
            'applicationDeadline',
        ];

        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || trim((string) $data[$field]) === '') {
                return $this->json(['message' => $field . ' is required.'], 400);
            }
        }

        try {
            $deadline = new \DateTimeImmutable($data['applicationDeadline']);
        } catch (\Throwable $e) {
            return $this->json(['message' => 'Invalid application deadline.'], 400);
        }

        $job->setTitle(trim($data['title']));
        $job->setCompanyName(trim($data['companyName']));
        $job->setLocation(trim($data['location']));
        $job->setJobType(trim($data['jobType']));
        $job->setWorkMode(trim($data['workMode']));
        $job->setCategory(trim($data['category']));
        $job->setDescription(trim($data['description']));
        $job->setRequirements(isset($data['requirements']) ? trim((string) $data['requirements']) : null);
        $job->setApplicationDeadline($deadline);
        $job->setCvRequired((bool) ($data['cvRequired'] ?? true));
        $job->setCoverLetterRequired((bool) ($data['coverLetterRequired'] ?? false));
        $job->setUpdatedAt(new \DateTimeImmutable());

        foreach ($job->getTasks() as $existingTask) {
            $job->removeTask($existingTask);
            $entityManager->remove($existingTask);
        }

        $tasksData = $data['tasks'] ?? [];

        if (is_array($tasksData)) {
            foreach ($tasksData as $taskData) {
                if (!is_array($taskData)) continue;

                $taskName = trim((string) ($taskData['taskName'] ?? ''));

                if ($taskName === '') continue;

                $task = new JobTask();
                $task->setTaskName($taskName);
                $task->setDescription(isset($taskData['description']) ? trim((string) $taskData['description']) : null);
                $task->setFeasibilityLevel(trim((string) ($taskData['feasibilityLevel'] ?? 'not_calculated')));
                $task->setRequiredAbilities(
                    is_array($taskData['requiredAbilities'] ?? null)
                        ? $taskData['requiredAbilities']
                        : []
                );

                $job->addTask($task);
            }
        }

        $entityManager->flush();

        return $this->json([
            'message' => 'Job updated successfully.',
            'job' => $this->formatJob($job),
        ]);
    }

    #[Route('/api/employer/jobs/{id}', name: 'api_employer_jobs_delete', methods: ['DELETE'])]
    public function deleteJob(
        int $id,
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $employerCheck = $this->verifyEmployer($request, $jwtEncoder);

        if ($employerCheck instanceof JsonResponse) {
            return $employerCheck;
        }

        $employer = $this->getEmployerFromToken($employerCheck, $entityManager);

        if (!$employer) {
            return $this->json(['message' => 'Employer user not found.'], 404);
        }

        $job = $entityManager->getRepository(JobPost::class)->find($id);

        if (!$job) {
            return $this->json(['message' => 'Job not found.'], 404);
        }

        if ($job->getEmployer()?->getId() !== $employer->getId() && !in_array('ROLE_SUPER_ADMIN', $employer->getRoles(), true)) {
            return $this->json(['message' => 'You cannot delete this job.'], 403);
        }

        $entityManager->remove($job);
        $entityManager->flush();

        return $this->json([
            'message' => 'Job deleted successfully.',
        ]);
    }

    #[Route('/api/jobs', name: 'api_public_jobs_list', methods: ['GET'])]
    public function listPublishedJobs(EntityManagerInterface $entityManager): JsonResponse
    {
        $jobs = $entityManager
            ->getRepository(JobPost::class)
            ->findBy(['status' => 'published'], ['id' => 'DESC']);

        return $this->json([
            'jobs' => array_map(fn (JobPost $job) => $this->formatJob($job), $jobs),
        ]);
    }
}