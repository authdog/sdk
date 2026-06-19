<?php

namespace Authdog\Types;

/**
 * User name information
 */
class Names
{
    public string $id;
    public ?string $formatted;
    public string $familyName;
    public string $givenName;
    public ?string $middleName;
    public ?string $honorificPrefix;
    public ?string $honorificSuffix;

    public function __construct(array $data)
    {
        $this->id = $data['id'] ?? '';
        $this->formatted = $data['formatted'] ?? null;
        $this->familyName = $data['familyName'] ?? '';
        $this->givenName = $data['givenName'] ?? '';
        $this->middleName = $data['middleName'] ?? null;
        $this->honorificPrefix = $data['honorificPrefix'] ?? null;
        $this->honorificSuffix = $data['honorificSuffix'] ?? null;
    }
}
