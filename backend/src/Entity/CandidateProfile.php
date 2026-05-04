<?php

namespace App\Entity;

use App\Repository\CandidateProfileRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CandidateProfileRepository::class)]
class CandidateProfile
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\OneToOne(inversedBy: 'candidateProfile')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private ?User $user = null;

    #[ORM\Column(type: 'json')]
    private array $selectedDisabilities = [];

    #[ORM\Column(type: 'json')]
    private array $remainingAbilities = [];

    #[ORM\Column(nullable: true)]
    private ?\DateTimeImmutable $updatedAt = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUser(): ?User
    {
        return $this->user;
    }

    public function setUser(User $user): static
    {
        $this->user = $user;
        return $this;
    }

    public function getSelectedDisabilities(): array
    {
        return $this->selectedDisabilities;
    }

    public function setSelectedDisabilities(array $selectedDisabilities): static
    {
        $this->selectedDisabilities = $selectedDisabilities;
        return $this;
    }

    public function getRemainingAbilities(): array
    {
        return $this->remainingAbilities;
    }

    public function setRemainingAbilities(array $remainingAbilities): static
    {
        $this->remainingAbilities = $remainingAbilities;
        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeImmutable $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }
}