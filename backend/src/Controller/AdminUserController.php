<?php

namespace App\Controller;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;

final class AdminUserController extends AbstractController
{
    private function verifyAdmin(Request $request, JWTEncoderInterface $jwtEncoder): array|JsonResponse
    {
        $token = $request->headers->get('X-Auth-Token');

        if (!$token) {
            return $this->json([
                'message' => 'Missing authentication token.'
            ], 401);
        }

        try {
            $decodedToken = $jwtEncoder->decode($token);
        } catch (\Throwable $e) {
            return $this->json([
                'message' => 'Invalid authentication token.',
                'error' => $e->getMessage()
            ], 401);
        }

        $roles = $decodedToken['roles'] ?? [];

        if (!in_array('ROLE_ADMIN', $roles, true)) {
            return $this->json([
                'message' => 'Access denied. Admin role required.'
            ], 403);
        }

        return $decodedToken;
    }

    private function formatUser(User $user): array
    {
        return [
            'id' => $user->getId(),
            'username' => $user->getUsername(),
            'email' => $user->getEmail(),
            'roles' => $user->getRoles(),
            'isVerified' => $user->isVerified(),
            'isArchived' => $user->isArchived(),
        ];
    }

    private function sendVerificationEmail(User $user, MailerInterface $mailer): void
    {
        $baseUrl = $_ENV['VERIFICATION_BASE_URL'] ?? 'https://fyp-backend-cbaa.onrender.com';

        $verificationLink = $baseUrl . '/api/verify-email?token=' . $user->getVerificationToken();

        $email = (new Email())
            ->from($_ENV['MAILER_FROM'] ?? 'inclusive.web.platform@outlook.com')
            ->to($user->getEmail())
            ->subject('Verify your John Hospitality account')
            ->text(
                "Hello " . $user->getUsername() . ",\n\n" .
                "Your email address was updated by an administrator. " .
                "Please verify your new email by clicking the link below:\n\n" .
                $verificationLink . "\n\n" .
                "Thank you."
            )
            ->html(
                '<p>Hello <strong>' . htmlspecialchars($user->getUsername(), ENT_QUOTES, 'UTF-8') . '</strong>,</p>' .
                '<p>Your email address was updated by an administrator.</p>' .
                '<p>Please verify your new email by clicking the link below:</p>' .
                '<p><a href="' . htmlspecialchars($verificationLink, ENT_QUOTES, 'UTF-8') . '">Verify email</a></p>' .
                '<p>Thank you.</p>'
            );

        $mailer->send($email);
    }

    #[Route('/api/admin/users', name: 'api_admin_users_list', methods: ['GET'])]
    public function listUsers(
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $adminCheck = $this->verifyAdmin($request, $jwtEncoder);

        if ($adminCheck instanceof JsonResponse) {
            return $adminCheck;
        }

        $users = $entityManager
            ->getRepository(User::class)
            ->findBy(['isArchived' => false], ['id' => 'ASC']);

        $usersData = [];

        foreach ($users as $user) {
            $usersData[] = $this->formatUser($user);
        }

        return $this->json([
            'users' => $usersData,
        ]);
    }

    #[Route('/api/admin/users/archived', name: 'api_admin_users_archived', methods: ['GET'])]
    public function listArchivedUsers(
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $adminCheck = $this->verifyAdmin($request, $jwtEncoder);

        if ($adminCheck instanceof JsonResponse) {
            return $adminCheck;
        }

        $users = $entityManager
            ->getRepository(User::class)
            ->findBy(['isArchived' => true], ['id' => 'ASC']);

        $usersData = [];

        foreach ($users as $user) {
            $usersData[] = $this->formatUser($user);
        }

        return $this->json([
            'users' => $usersData,
        ]);
    }

    #[Route('/api/admin/users/{id<\d+>}', name: 'api_admin_users_update', methods: ['PATCH'])]
    public function updateUser(
        int $id,
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder,
        UserPasswordHasherInterface $passwordHasher,
        MailerInterface $mailer
    ): JsonResponse {
        $adminCheck = $this->verifyAdmin($request, $jwtEncoder);

        if ($adminCheck instanceof JsonResponse) {
            return $adminCheck;
        }

        $user = $entityManager
            ->getRepository(User::class)
            ->find($id);

        if (!$user) {
            return $this->json([
                'message' => 'User not found.'
            ], 404);
        }

        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json([
                'message' => 'Invalid request body.'
            ], 400);
        }

        $username = trim($data['username'] ?? '');
        $email = trim($data['email'] ?? '');
        $password = trim($data['password'] ?? '');

        if ($username === '' || $email === '') {
            return $this->json([
                'message' => 'Username and email are required.'
            ], 400);
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return $this->json([
                'message' => 'Invalid email format.'
            ], 400);
        }

        $existingUsernameUser = $entityManager
            ->getRepository(User::class)
            ->findOneBy(['username' => $username]);

        if ($existingUsernameUser && $existingUsernameUser->getId() !== $user->getId()) {
            return $this->json([
                'message' => 'This username is already used.'
            ], 409);
        }

        $existingEmailUser = $entityManager
            ->getRepository(User::class)
            ->findOneBy(['email' => $email]);

        if ($existingEmailUser && $existingEmailUser->getId() !== $user->getId()) {
            return $this->json([
                'message' => 'This email is already used.'
            ], 409);
        }

        $emailChanged = strtolower($email) !== strtolower((string) $user->getEmail());

        $user->setUsername($username);

        if ($emailChanged) {
            $verificationToken = bin2hex(random_bytes(32));

            $user->setEmail($email);
            $user->setIsVerified(false);
            $user->setVerificationToken($verificationToken);
        }

        if ($password !== '') {
            if (strlen($password) < 8) {
                return $this->json([
                    'message' => 'Password must be at least 8 characters long.'
                ], 400);
            }

            $hashedPassword = $passwordHasher->hashPassword($user, $password);
            $user->setPassword($hashedPassword);
        }

        $entityManager->flush();

        $emailSendFailed = false;
        $emailSendError = null;

        if ($emailChanged) {
            try {
                $this->sendVerificationEmail($user, $mailer);
            } catch (\Throwable $e) {
                $emailSendFailed = true;
                $emailSendError = $e->getMessage();
            }
        }

        return $this->json([
            'message' => $emailChanged
                ? (
                    $emailSendFailed
                        ? 'User updated, but the verification email could not be sent.'
                        : 'User updated successfully. A new verification email was sent.'
                )
                : 'User updated successfully.',
            'user' => $this->formatUser($user),
            'emailVerificationRequired' => $emailChanged,
            'emailSendFailed' => $emailSendFailed,
            'emailSendError' => $emailSendError,
        ], $emailSendFailed ? 207 : 200);
    }

    #[Route('/api/admin/users/{id<\d+>}/archive', name: 'api_admin_users_archive', methods: ['PATCH'])]
    public function archiveUser(
        int $id,
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $adminCheck = $this->verifyAdmin($request, $jwtEncoder);

        if ($adminCheck instanceof JsonResponse) {
            return $adminCheck;
        }

        $user = $entityManager
            ->getRepository(User::class)
            ->find($id);

        if (!$user) {
            return $this->json([
                'message' => 'User not found.'
            ], 404);
        }

        $currentAdminEmail = $adminCheck['username'] ?? null;

        if ($currentAdminEmail === $user->getEmail()) {
            return $this->json([
                'message' => 'You cannot archive your own admin account.'
            ], 400);
        }

        $user->setIsArchived(true);
        $entityManager->flush();

        return $this->json([
            'message' => 'User archived successfully.',
            'user' => $this->formatUser($user),
        ], 200);
    }

    #[Route('/api/admin/users/{id<\d+>}/restore', name: 'api_admin_users_restore', methods: ['PATCH'])]
    public function restoreUser(
        int $id,
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $adminCheck = $this->verifyAdmin($request, $jwtEncoder);

        if ($adminCheck instanceof JsonResponse) {
            return $adminCheck;
        }

        $user = $entityManager
            ->getRepository(User::class)
            ->find($id);

        if (!$user) {
            return $this->json([
                'message' => 'User not found.'
            ], 404);
        }

        $user->setIsArchived(false);
        $entityManager->flush();

        return $this->json([
            'message' => 'User restored successfully.',
            'user' => $this->formatUser($user),
        ], 200);
    }

    #[Route('/api/admin/users/{id<\d+>}', name: 'api_admin_users_delete', methods: ['DELETE'])]
    public function deleteUser(
        int $id,
        Request $request,
        EntityManagerInterface $entityManager,
        JWTEncoderInterface $jwtEncoder
    ): JsonResponse {
        $adminCheck = $this->verifyAdmin($request, $jwtEncoder);

        if ($adminCheck instanceof JsonResponse) {
            return $adminCheck;
        }

        $user = $entityManager
            ->getRepository(User::class)
            ->find($id);

        if (!$user) {
            return $this->json([
                'message' => 'User not found.'
            ], 404);
        }

        $currentAdminEmail = $adminCheck['username'] ?? null;

        if ($currentAdminEmail === $user->getEmail()) {
            return $this->json([
                'message' => 'You cannot delete your own admin account.'
            ], 400);
        }

        $entityManager->remove($user);
        $entityManager->flush();

        return $this->json([
            'message' => 'User deleted successfully.'
        ], 200);
    }
}