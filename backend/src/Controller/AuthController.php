<?php

namespace App\Controller;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;

final class AuthController extends AbstractController
{
    #[Route('/api/register', name: 'api_register', methods: ['POST'])]
    public function register(
        Request $request,
        EntityManagerInterface $entityManager,
        UserPasswordHasherInterface $passwordHasher,
        MailerInterface $mailer
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (
            !$data ||
            !isset($data['username']) ||
            !isset($data['email']) ||
            !isset($data['password'])
        ) {
            return $this->json([
                'message' => 'Username, email and password are required.'
            ], 400);
        }

        $username = trim($data['username']);
        $emailAddress = trim($data['email']);
        $password = $data['password'];

        if (strlen($username) < 2) {
            return $this->json([
                'message' => 'Username must contain at least 2 characters.'
            ], 400);
        }

        if (!filter_var($emailAddress, FILTER_VALIDATE_EMAIL)) {
            return $this->json([
                'message' => 'Invalid email address.'
            ], 400);
        }

        if (
            strlen($password) < 8 ||
            !preg_match('/[a-z]/', $password) ||
            !preg_match('/[A-Z]/', $password) ||
            !preg_match('/[\W_]/', $password)
        ) {
            return $this->json([
                'message' => 'Password must be at least 8 characters and contain one lowercase letter, one uppercase letter, and one symbol.'
            ], 400);
        }

        $existingUserByEmail = $entityManager->getRepository(User::class)->findOneBy([
            'email' => $emailAddress
        ]);

        if ($existingUserByEmail) {
            return $this->json([
                'message' => 'This email is already registered.'
            ], 409);
        }

        $existingUserByUsername = $entityManager->getRepository(User::class)->findOneBy([
            'username' => $username
        ]);

        if ($existingUserByUsername) {
            return $this->json([
                'message' => 'This username is already taken.'
            ], 409);
        }

        $verificationToken = bin2hex(random_bytes(32));

        $user = new User();
        $user->setUsername($username);
        $user->setEmail($emailAddress);
        $user->setRoles(['ROLE_USER']);
        $user->setIsVerified(false);
        $user->setVerificationToken($verificationToken);
        $user->setPassword(
            $passwordHasher->hashPassword($user, $password)
        );

        $entityManager->persist($user);
        $entityManager->flush();

        $baseUrl = $_ENV['VERIFICATION_BASE_URL'] ?? 'http://127.0.0.1:8081/index.php';
        $verificationLink = $baseUrl . '/api/verify-email?token=' . $verificationToken;

        $email = (new Email())
            ->from('inclusive.web.platform@outlook.com')
            ->to($user->getEmail())
            ->subject('Verify your email')
            ->text(
                "Welcome {$user->getUsername()}!\n\n" .
                "Please verify your email by clicking this link:\n" .
                $verificationLink . "\n\n" .
                "If you did not create this account, you can ignore this email."
            );

        $mailer->send($email);

        return $this->json([
            'message' => 'User registered successfully. Please check your email to verify your account.'
        ], 201);
    }

    #[Route('/api/verify-email', name: 'api_verify_email', methods: ['GET'])]
    public function verifyEmail(
        Request $request,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $token = $request->query->get('token');

        if (!$token) {
            return $this->json([
                'message' => 'Verification token is missing.'
            ], 400);
        }

        $user = $entityManager->getRepository(User::class)->findOneBy([
            'verificationToken' => $token
        ]);

        if (!$user) {
            return $this->json([
                'message' => 'Invalid verification token.'
            ], 404);
        }

        $user->setIsVerified(true);
        $user->setVerificationToken(null);

        $entityManager->flush();

        return $this->json([
            'message' => 'Email verified successfully. You can now log in.'
        ], 200);
    }
}