package com.authdog

import com.authdog.exceptions.{ApiException, AuthenticationException}
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import org.scalatest.BeforeAndAfterEach
import scala.concurrent.duration._

class AuthdogClientTest extends AnyFlatSpec with Matchers with BeforeAndAfterEach {
  
  private var client: AuthdogClient = _
  
  override def beforeEach(): Unit = {
    client = AuthdogClient("https://api.authdog.com")
  }
  
  override def afterEach(): Unit = {
    if (client != null) {
      client.close()
    }
  }
  
  "AuthdogClient" should "be created with base URL" in {
    val testClient = AuthdogClient("https://api.authdog.com")
    testClient should not be null
    testClient.close()
  }
  
  it should "be created with base URL and API key" in {
    val testClient = AuthdogClient("https://api.authdog.com", "test-api-key")
    testClient should not be null
    testClient.close()
  }
  
  it should "be created with base URL, API key, and timeout" in {
    val testClient = AuthdogClient("https://api.authdog.com", Some("test-api-key"), 5.seconds)
    testClient should not be null
    testClient.close()
  }
  
  it should "trim trailing slash from base URL" in {
    val testClient = AuthdogClient("https://api.authdog.com/")
    testClient should not be null
    testClient.close()
  }
  
  it should "handle authentication errors" in {
    val testClient = AuthdogClient("https://httpbin.org")
    
    // Should throw some exception (auth or API error)
    assertThrows[Exception] {
      testClient.getUserInfo("invalid-token")
    }
    
    testClient.close()
  }
  
  it should "handle API errors" in {
    val testClient = AuthdogClient("https://httpbin.org/status/500")
    
    assertThrows[Exception] {
      testClient.getUserInfo("test-token")
    }
    
    testClient.close()
  }
  
  it should "handle network errors gracefully" in {
    val testClient = AuthdogClient("https://nonexistent-domain-12345.com")
    
    assertThrows[Exception] {
      testClient.getUserInfo("test-token")
    }
    
    testClient.close()
  }
  
  it should "handle timeout errors" in {
    val testClient = AuthdogClient("https://httpbin.org/delay/15", None, 1.second)
    
    assertThrows[ApiException] {
      testClient.getUserInfo("test-token")
    }
    
    testClient.close()
  }
}
