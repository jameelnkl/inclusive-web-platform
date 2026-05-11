<?php

namespace App\Entity;

use App\Repository\JobPostRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: JobPostRepository::class)]
class JobPost
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $employer = null;

    #[ORM\Column(length: 255)]
    private ?string $title = null;

    #[ORM\Column(length: 255)]
    private ?string $companyName = null;

    #[ORM\Column(length: 255)]
    private ?string $location = null;

    #[ORM\Column(length: 50)]
    private ?string $jobType = null;

    #[ORM\Column(length: 50)]
    private ?string $workMode = null;

    #[ORM\Column(length: 100)]
    private ?string $category = null;

    #[ORM\Column(type: 'text')]
    private ?string $description = null;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $requirements = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $applicationDeadline = null;

    #[ORM\Column(options: ['default' => true])]
    private bool $cvRequired = true;

    #[ORM\Column(options: ['default' => false])]
    private bool $coverLetterRequired = false;

    #[ORM\Column(length: 50)]
    private ?string $status = 'published';

    #[ORM\Column]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $updatedAt = null;

    #[ORM\OneToMany(mappedBy: 'jobPost', targetEntity: JobTask::class, cascade: ['persist', 'remove'], orphanRemoval: true)]
    private Collection $tasks;

    public function __construct()
    {
        $this->tasks = new ArrayCollection();
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
        $this->status = 'published';
    }

    public function getId(): ?int { return $this->id; }

    public function getEmployer(): ?User { return $this->employer; }

    public function setEmployer(?User $employer): static
    {
        $this->employer = $employer;
        return $this;
    }

    public function getTitle(): ?string { return $this->title; }

    public function setTitle(string $title): static
    {
        $this->title = $title;
        return $this;
    }

    public function getCompanyName(): ?string { return $this->companyName; }

    public function setCompanyName(string $companyName): static
    {
        $this->companyName = $companyName;
        return $this;
    }

    public function getLocation(): ?string { return $this->location; }

    public function setLocation(string $location): static
    {
        $this->location = $location;
        return $this;
    }

    public function getJobType(): ?string { return $this->jobType; }

    public function setJobType(string $jobType): static
    {
        $this->jobType = $jobType;
        return $this;
    }

    public function getWorkMode(): ?string { return $this->workMode; }

    public function setWorkMode(string $workMode): static
    {
        $this->workMode = $workMode;
        return $this;
    }

    public function getCategory(): ?string { return $this->category; }

    public function setCategory(string $category): static
    {
        $this->category = $category;
        return $this;
    }

    public function getDescription(): ?string { return $this->description; }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getRequirements(): ?string { return $this->requirements; }

    public function setRequirements(?string $requirements): static
    {
        $this->requirements = $requirements;
        return $this;
    }

    public function getApplicationDeadline(): ?\DateTimeImmutable
    {
        return $this->applicationDeadline;
    }

    public function setApplicationDeadline(\DateTimeImmutable $applicationDeadline): static
    {
        $this->applicationDeadline = $applicationDeadline;
        return $this;
    }

    public function isCvRequired(): bool { return $this->cvRequired; }

    public function setCvRequired(bool $cvRequired): static
    {
        $this->cvRequired = $cvRequired;
        return $this;
    }

    public function isCoverLetterRequired(): bool { return $this->coverLetterRequired; }

    public function setCoverLetterRequired(bool $coverLetterRequired): static
    {
        $this->coverLetterRequired = $coverLetterRequired;
        return $this;
    }

    public function getStatus(): ?string { return $this->status; }

    public function setStatus(string $status): static
    {
        $this->status = $status;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable { return $this->createdAt; }

    public function getUpdatedAt(): ?\DateTimeImmutable { return $this->updatedAt; }

    public function setUpdatedAt(\DateTimeImmutable $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    /**
     * @return Collection<int, JobTask>
     */
    public function getTasks(): Collection
    {
        return $this->tasks;
    }

    public function addTask(JobTask $task): static
    {
        if (!$this->tasks->contains($task)) {
            $this->tasks->add($task);
            $task->setJobPost($this);
        }

        return $this;
    }

    public function removeTask(JobTask $task): static
    {
        if ($this->tasks->removeElement($task)) {
            if ($task->getJobPost() === $this) {
                $task->setJobPost(null);
            }
        }

        return $this;
    }
}