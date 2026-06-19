<?php

namespace Authdog\Types;

/**
 * Response from the /v1/userinfo endpoint
 */
class UserInfoResponse
{
    public Meta $meta;
    public Session $session;
    public User $user;

    public function __construct(array $data)
    {
        $this->meta = new Meta($data['meta'] ?? []);
        $this->session = new Session($data['session'] ?? []);
        $this->user = new User($data['user'] ?? []);
    }

    public function getMeta(): Meta
    {
        return $this->meta;
    }

    public function getSession(): Session
    {
        return $this->session;
    }

    public function getUser(): User
    {
        return $this->user;
    }
}
