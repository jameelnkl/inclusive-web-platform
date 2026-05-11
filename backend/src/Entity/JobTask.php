<?php

namespace App\Entity;

use App\Repository\JobTaskRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: JobTaskRepository::class)]
class JobTask
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\ManyToOne(targetEntity: JobPost::class, inversedBy: 'tasks')]
    #[ORM\JoinColumn(nullable: false)]
    private ?JobPost $jobPost = null;

    #[ORM\Column(length: 255)]
    private ?string $taskName = null;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $description = null;

    #[ORM\Column(length: 50)]
    private ?string $feasibilityLevel = null;

    #[ORM\Column(type: 'json')]
    private array $requiredAbilities = [];

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getJobPost(): ?JobPost
    {
        return $this->jobPost;
    }

    public function setJobPost(?JobPost $jobPost): static
    {
        $this->jobPost = $jobPost;
        return $this;
    }

    public function getTaskName(): ?string
    {
        return $this->taskName;
    }

    public function setTaskName(string $taskName): static
    {
        $this->taskName = $taskName;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getFeasibilityLevel(): ?string
    {
        return $this->feasibilityLevel;
    }

    public function setFeasibilityLevel(string $feasibilityLevel): static
    {
        $this->feasibilityLevel = $feasibilityLevel;
        return $this;
    }

    public function getRequiredAbilities(): array
    {
        return $this->requiredAbilities;
    }

    public function setRequiredAbilities(array $requiredAbilities): static
    {
        $this->requiredAbilities = $requiredAbilities;
        return $this;
    }
}