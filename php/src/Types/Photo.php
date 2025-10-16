<?php

namespace Authdog\Types;

/**
 * User photo
 */
class Photo
{
    public string $id;
    public string $value;
    public string $type;

    public function __construct(array $data)
    {
        $this->id = $data['id'] ?? '';
        $this->value = $data['value'] ?? '';
        $this->type = $data['type'] ?? '';
    }
}
