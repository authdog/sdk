package com.authdog.exceptions

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

class ExceptionTest extends AnyFlatSpec with Matchers {
  
  "AuthdogException" should "be created with message" in {
    val exception = AuthdogException("Test error message")
    exception.getMessage shouldBe "Test error message"
    exception.getCause shouldBe null
  }
  
  it should "be created with message and cause" in {
    val cause = new RuntimeException("Root cause")
    val exception = AuthdogException("Test error message", cause)
    exception.getMessage shouldBe "Test error message"
    exception.getCause shouldBe cause
  }
  
  it should "extend RuntimeException" in {
    val exception = AuthdogException("Test error")
    exception shouldBe a[RuntimeException]
  }
  
  "ApiException" should "be created with message" in {
    val exception = ApiException("API error message")
    exception.getMessage shouldBe "API error message"
    exception shouldBe a[AuthdogException]
  }
  
  it should "be created with message and cause" in {
    val cause = new RuntimeException("Root cause")
    val exception = ApiException("API error message", cause)
    exception.getMessage shouldBe "API error message"
    exception.getCause shouldBe cause
    exception shouldBe a[AuthdogException]
  }
  
  "AuthenticationException" should "be created with message" in {
    val exception = AuthenticationException("Authentication error message")
    exception.getMessage shouldBe "Authentication error message"
    exception shouldBe a[AuthdogException]
  }
  
  it should "be created with message and cause" in {
    val cause = new RuntimeException("Root cause")
    val exception = AuthenticationException("Authentication error message", cause)
    exception.getMessage shouldBe "Authentication error message"
    exception.getCause shouldBe cause
    exception shouldBe a[AuthdogException]
  }
}
