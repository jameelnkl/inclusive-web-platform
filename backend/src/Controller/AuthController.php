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

        $sendVerificationEmail = $data['sendVerificationEmail'] ?? true;

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

        if ($sendVerificationEmail) {
            $baseUrl = $_ENV['VERIFICATION_BASE_URL'] ?? 'http://localhost:8081';
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
        }

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

    #[Route('/api/forgot-password', name: 'api_forgot_password', methods: ['POST'])]
    public function forgotPassword(
        Request $request,
        EntityManagerInterface $entityManager,
        MailerInterface $mailer
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (!$data || !isset($data['email'])) {
            return $this->json([
                'message' => 'Email is required.'
            ], 400);
        }

        $emailAddress = trim($data['email']);

        $user = $entityManager->getRepository(User::class)->findOneBy([
            'email' => $emailAddress
        ]);

        // Always return success even if email not found (security best practice)
        if (!$user) {
            return $this->json([
                'message' => 'If this email exists, a reset link has been sent.'
            ], 200);
        }

        $resetToken = bin2hex(random_bytes(32));
        $expiresAt = new \DateTimeImmutable('+1 hour');

        $user->setResetPasswordToken($resetToken);
        $user->setResetPasswordExpiresAt($expiresAt);

        $entityManager->flush();

        $frontendUrl = $_ENV['FRONTEND_URL'] ?? 'http://localhost:5173';
        $resetLink = $frontendUrl . '/reset-password?token=' . $resetToken;

        $email = (new Email())
            ->from('inclusive.web.platform@outlook.com')
            ->to($user->getEmail())
            ->subject('Reset your password')
            ->text(
                "Hi {$user->getUsername()},\n\n" .
                "You requested to reset your password. Click the link below to set a new password:\n\n" .
                $resetLink . "\n\n" .
                "This link will expire in 1 hour.\n\n" .
                "If you did not request a password reset, you can ignore this email."
            );

        $mailer->send($email);

        return $this->json([
            'message' => 'If this email exists, a reset link has been sent.'
        ], 200);
    }

    #[Route('/api/reset-password', name: 'api_reset_password', methods: ['POST'])]
    public function resetPassword(
        Request $request,
        EntityManagerInterface $entityManager,
        UserPasswordHasherInterface $passwordHasher
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (!$data || !isset($data['token']) || !isset($data['password'])) {
            return $this->json([
                'message' => 'Token and new password are required.'
            ], 400);
        }

        $token = $data['token'];
        $newPassword = $data['password'];

        $user = $entityManager->getRepository(User::class)->findOneBy([
            'resetPasswordToken' => $token
        ]);

        if (!$user) {
            return $this->json([
                'message' => 'Invalid or expired reset token.'
            ], 400);
        }

        if ($user->getResetPasswordExpiresAt() < new \DateTimeImmutable()) {
            return $this->json([
                'message' => 'This reset link has expired. Please request a new one.'
            ], 400);
        }

        if (
            strlen($newPassword) < 8 ||
            !preg_match('/[a-z]/', $newPassword) ||
            !preg_match('/[A-Z]/', $newPassword) ||
            !preg_match('/[\W_]/', $newPassword)
        ) {
            return $this->json([
                'message' => 'Password must be at least 8 characters and contain one lowercase letter, one uppercase letter, and one symbol.'
            ], 400);
        }

        $user->setPassword($passwordHasher->hashPassword($user, $newPassword));
        $user->setResetPasswordToken(null);
        $user->setResetPasswordExpiresAt(null);

        $entityManager->flush();

        return $this->json([
            'message' => 'Password reset successfully. You can now log in.'
        ], 200);
    }
}