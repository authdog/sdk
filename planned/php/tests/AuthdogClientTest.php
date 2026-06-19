<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use Authdog\AuthdogClient;
use Authdog\Types\UserInfoResponse;

final class AuthdogClientTest extends TestCase
{
    public function testClientCanBeConstructed(): void
    {
        $client = new AuthdogClient('https://example.com', 'test-token');
        $this->assertInstanceOf(AuthdogClient::class, $client);
    }

    public function testUserInfoResponseModel(): void
    {
        $data = [
            'user' => [
                'id' => 'u_123',
                'emails' => [
                    [
                        'id' => 'email_123',
                        'value' => 'john@example.com',
                        'type' => 'work'
                    ]
                ],
            ],
            'meta' => [
                'requestId' => 'req_123',
            ],
            'session' => [
                'remainingSeconds' => 3600,
            ],
        ];

        $response = new UserInfoResponse($data);
        $this->assertSame('u_123', $response->getUser()->getId());
        $this->assertSame('john@example.com', $response->getUser()->getEmail()->getAddress());
        $this->assertSame('req_123', $response->getMeta()->get('requestId'));
    }
}


