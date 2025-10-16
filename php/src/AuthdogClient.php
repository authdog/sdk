<?php

namespace Authdog;

use Authdog\Exceptions\AuthenticationException;
use Authdog\Exceptions\ApiException;
use Authdog\Types\UserInfoResponse;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use GuzzleHttp\Exception\RequestException;

/**
 * Main client for interacting with Authdog API
 */
class AuthdogClient
{
    private Client $httpClient;
    private string $baseUrl;
    private ?string $apiKey;

    /**
     * Initialize the Authdog client
     *
     * @param string $baseUrl The base URL of the Authdog API
     * @param string|null $apiKey Optional API key for authentication
     * @param array $options Additional Guzzle HTTP client options
     */
    public function __construct(string $baseUrl, ?string $apiKey = null, array $options = [])
    {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->apiKey = $apiKey;

        $defaultOptions = [
            'base_uri' => $this->baseUrl,
            'timeout' => 10,
            'headers' => [
                'Content-Type' => 'application/json',
                'User-Agent' => 'authdog-php-sdk/0.1.0',
            ],
        ];

        if ($this->apiKey) {
            $defaultOptions['headers']['Authorization'] = 'Bearer ' . $this->apiKey;
        }

        $this->httpClient = new Client(array_merge($defaultOptions, $options));
    }

    /**
     * Get user information using an access token
     *
     * @param string $accessToken The access token for authentication
     * @return UserInfoResponse User information
     * @throws AuthenticationException When authentication fails
     * @throws ApiException When API request fails
     */
    public function getUserInfo(string $accessToken): UserInfoResponse
    {
        try {
            $response = $this->httpClient->get('/v1/userinfo', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                ],
            ]);

            $data = json_decode($response->getBody()->getContents(), true);
            return new UserInfoResponse($data);

        } catch (RequestException $e) {
            $statusCode = $e->getResponse() ? $e->getResponse()->getStatusCode() : 0;
            $responseBody = $e->getResponse() ? $e->getResponse()->getBody()->getContents() : '';

            if ($statusCode === 401) {
                throw new AuthenticationException('Unauthorized - invalid or expired token');
            }

            if ($statusCode === 500) {
                $errorData = json_decode($responseBody, true);
                if (isset($errorData['error'])) {
                    if ($errorData['error'] === 'GraphQL query failed') {
                        throw new ApiException('GraphQL query failed');
                    } elseif ($errorData['error'] === 'Failed to fetch user info') {
                        throw new ApiException('Failed to fetch user info');
                    }
                }
            }

            throw new ApiException("HTTP error {$statusCode}: {$responseBody}");
        } catch (GuzzleException $e) {
            throw new ApiException('Request failed: ' . $e->getMessage());
        }
    }

    /**
     * Close the HTTP client (for cleanup)
     */
    public function close(): void
    {
        // Guzzle HTTP client doesn't require explicit cleanup
    }
}
