<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
class JobApplication
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $candidate = null;

    #[ORM\ManyToOne(targetEntity: JobPost::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?JobPost $jobPost = null;

    #[ORM\Column(length: 50)]
    private ?string $status = 'pending';

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $applicationFileName = null;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $applicationOriginalName = null;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $recommendationFileName = null;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $recommendationOriginalName = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $updatedAt = null;

    public function __construct()
    {
        $this->status = 'pending';
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int { return $this->id; }

    public function getCandidate(): ?User { return $this->candidate; }

    public function setCandidate(?User $candidate): static
    {
        $this->candidate = $candidate;
        return $this;
    }

    public function getJobPost(): ?JobPost { return $this->jobPost; }

    public function setJobPost(?JobPost $jobPost): static
    {
        $this->jobPost = $jobPost;
        return $this;
    }

    public function getStatus(): ?string { return $this->status; }

    public function setStatus(string $status): static
    {
        $this->status = $status;
        $this->updatedAt = new \DateTimeImmutable();
        return $this;
    }

    public function getApplicationFileName(): ?string { return $this->applicationFileName; }

    public function setApplicationFileName(?string $applicationFileName): static
    {
        $this->applicationFileName = $applicationFileName;
        return $this;
    }

    public function getApplicationOriginalName(): ?string { return $this->applicationOriginalName; }

    public function setApplicationOriginalName(?string $applicationOriginalName): static
    {
        $this->applicationOriginalName = $applicationOriginalName;
        return $this;
    }

    public function getRecommendationFileName(): ?string { return $this->recommendationFileName; }

    public function setRecommendationFileName(?string $recommendationFileName): static
    {
        $this->recommendationFileName = $recommendationFileName;
        return $this;
    }

    public function getRecommendationOriginalName(): ?string { return $this->recommendationOriginalName; }

    public function setRecommendationOriginalName(?string $recommendationOriginalName): static
    {
        $this->recommendationOriginalName = $recommendationOriginalName;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable { return $this->createdAt; }

    public function getUpdatedAt(): ?\DateTimeImmutable { return $this->updatedAt; }

    public function setUpdatedAt(\DateTimeImmutable $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }
}