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
    private function isPasswordValid(string $password): bool
    {
        return strlen($password) >= 8 &&
            preg_match('/[a-z]/', $password) &&
            preg_match('/[A-Z]/', $password) &&
            preg_match('/[\W_]/', $password);
    }

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
            !isset($data['password']) ||
            !isset($data['accountType'])
        ) {
            return $this->json([
                'message' => 'Username, email, password and account type are required.'
            ], 400);
        }

        $sendVerificationEmail = $data['sendVerificationEmail'] ?? true;

        $username = trim($data['username']);
        $emailAddress = trim($data['email']);
        $password = $data['password'];
        $accountType = $data['accountType'];

        if (!in_array($accountType, ['candidate', 'employer'], true)) {
            return $this->json([
                'message' => 'Invalid account type.'
            ], 400);
        }

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

        if (!$this->isPasswordValid($password)) {
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

        if ($accountType === 'employer') {
            $user->setRoles(['ROLE_EMPLOYER']);
        } else {
            $user->setRoles(['ROLE_USER']);
        }

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
                ->from($_ENV['MAILER_FROM'] ?? 'inclusive.web.platform@outlook.com')
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

        if (!filter_var($emailAddress, FILTER_VALIDATE_EMAIL)) {
            return $this->json([
                'message' => 'Invalid email address.'
            ], 400);
        }

        $user = $entityManager->getRepository(User::class)->findOneBy([
            'email' => $emailAddress
        ]);

        if ($user) {
            $resetToken = bin2hex(random_bytes(32));

            $user->setResetPasswordToken($resetToken);
            $user->setResetPasswordTokenExpiresAt(
                new \DateTimeImmutable('+1 hour')
            );

            $entityManager->flush();

            $frontendBaseUrl = $_ENV['RESET_PASSWORD_BASE_URL'] ?? 'http://localhost:5173';
            $resetLink = $frontendBaseUrl . '/reset-password?token=' . $resetToken;

            $email = (new Email())
                ->from($_ENV['MAILER_FROM'] ?? 'inclusive.web.platform@outlook.com')
                ->to($user->getEmail())
                ->subject('Reset your password')
                ->text(
                    "Hello {$user->getUsername()},\n\n" .
                    "We received a request to reset your password.\n\n" .
                    "Click this link to choose a new password:\n" .
                    $resetLink . "\n\n" .
                    "This link will expire in 1 hour.\n\n" .
                    "If you did not request this, you can ignore this email."
                );

            $mailer->send($email);
        }

        return $this->json([
            'message' => 'If an account exists with this email, a password reset link has been sent.'
        ], 200);
    }

    #[Route('/api/reset-password', name: 'api_reset_password', methods: ['POST'])]
    public function resetPassword(
        Request $request,
        EntityManagerInterface $entityManager,
        UserPasswordHasherInterface $passwordHasher
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (
            !$data ||
            !isset($data['token']) ||
            !isset($data['newPassword'])
        ) {
            return $this->json([
                'message' => 'Reset token and new password are required.'
            ], 400);
        }

        $token = trim($data['token']);
        $newPassword = $data['newPassword'];

        if (!$this->isPasswordValid($newPassword)) {
            return $this->json([
                'message' => 'Password must be at least 8 characters and contain one lowercase letter, one uppercase letter, and one symbol.'
            ], 400);
        }

        $user = $entityManager->getRepository(User::class)->findOneBy([
            'resetPasswordToken' => $token
        ]);

        if (!$user) {
            return $this->json([
                'message' => 'Invalid or expired password reset link.'
            ], 404);
        }

        $expiresAt = $user->getResetPasswordTokenExpiresAt();

        if (!$expiresAt || $expiresAt < new \DateTimeImmutable()) {
            $user->setResetPasswordToken(null);
            $user->setResetPasswordTokenExpiresAt(null);
            $entityManager->flush();

            return $this->json([
                'message' => 'Invalid or expired password reset link.'
            ], 400);
        }

        $user->setPassword(
            $passwordHasher->hashPassword($user, $newPassword)
        );

        $user->setResetPasswordToken(null);
        $user->setResetPasswordTokenExpiresAt(null);

        $entityManager->flush();

        return $this->json([
            'message' => 'Password reset successfully. You can now sign in.'
        ], 200);
    }
}