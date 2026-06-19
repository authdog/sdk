<?php

namespace Authdog\Types;

/**
 * Email verification status
 */
class Verification
{
    public string $id;
    public string $email;
    public bool $verified;
    public string $createdAt;
    public string $updatedAt;

    public function __construct(array $data)
    {
        $this->id = $data['id'] ?? '';
        $this->email = $data['email'] ?? '';
        $this->verified = $data['verified'] ?? false;
        $this->createdAt = $data['createdAt'] ?? '';
        $this->updatedAt = $data['updatedAt'] ?? '';
    }
}
