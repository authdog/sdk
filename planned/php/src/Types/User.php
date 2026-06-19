<?php

namespace Authdog\Types;

/**
 * User information
 */
class User
{
    public string $id;
    public string $externalId;
    public string $userName;
    public string $displayName;
    public ?string $nickName;
    public ?string $profileUrl;
    public ?string $title;
    public ?string $userType;
    public ?string $preferredLanguage;
    public string $locale;
    public ?string $timezone;
    public bool $active;
    public Names $names;
    /** @var Photo[] */
    public array $photos;
    /** @var array */
    public array $phoneNumbers;
    /** @var array */
    public array $addresses;
    /** @var Email[] */
    public array $emails;
    /** @var Verification[] */
    public array $verifications;
    public string $provider;
    public string $createdAt;
    public string $updatedAt;
    public string $environmentId;

    public function __construct(array $data)
    {
        $this->id = $data['id'] ?? '';
        $this->externalId = $data['externalId'] ?? '';
        $this->userName = $data['userName'] ?? '';
        $this->displayName = $data['displayName'] ?? '';
        $this->nickName = $data['nickName'] ?? null;
        $this->profileUrl = $data['profileUrl'] ?? null;
        $this->title = $data['title'] ?? null;
        $this->userType = $data['userType'] ?? null;
        $this->preferredLanguage = $data['preferredLanguage'] ?? null;
        $this->locale = $data['locale'] ?? '';
        $this->timezone = $data['timezone'] ?? null;
        $this->active = $data['active'] ?? false;
        $this->names = new Names($data['names'] ?? []);
        $this->photos = array_map(fn($photo) => new Photo($photo), $data['photos'] ?? []);
        $this->phoneNumbers = $data['phoneNumbers'] ?? [];
        $this->addresses = $data['addresses'] ?? [];
        $this->emails = array_map(fn($email) => new Email($email), $data['emails'] ?? []);
        $this->verifications = array_map(fn($verification) => new Verification($verification), $data['verifications'] ?? []);
        $this->provider = $data['provider'] ?? '';
        $this->createdAt = $data['createdAt'] ?? '';
        $this->updatedAt = $data['updatedAt'] ?? '';
        $this->environmentId = $data['environmentId'] ?? '';
    }

    public function getId(): string
    {
        return $this->id;
    }

    public function getEmail(): ?Email
    {
        return $this->emails[0] ?? null;
    }
}
