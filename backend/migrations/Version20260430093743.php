<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260430093743 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add reset_password_token and reset_password_expires_at to user table';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE "user" ADD reset_password_token VARCHAR(255) DEFAULT NULL');
        $this->addSql('ALTER TABLE "user" ADD reset_password_expires_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE "user" DROP COLUMN reset_password_token');
        $this->addSql('ALTER TABLE "user" DROP COLUMN reset_password_expires_at');
    }
}