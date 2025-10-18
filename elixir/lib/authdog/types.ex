defmodule Authdog.Types do
  @moduledoc """
  Type definitions for Authdog API responses.
  """

  defmodule Meta do
    @moduledoc "Metadata in the response"
    defstruct [:code, :message]

    @type t :: %__MODULE__{
            code: integer(),
            message: String.t()
          }

    def from_map(%{"code" => code, "message" => message}) do
      %__MODULE__{code: code, message: message}
    end
  end

  defmodule Session do
    @moduledoc "Session information"
    defstruct [:remaining_seconds]

    @type t :: %__MODULE__{
            remaining_seconds: integer()
          }

    def from_map(%{"remainingSeconds" => remaining_seconds}) do
      %__MODULE__{remaining_seconds: remaining_seconds}
    end
  end

  defmodule Names do
    @moduledoc "User name information"
    defstruct [
      :id,
      :formatted,
      :family_name,
      :given_name,
      :middle_name,
      :honorific_prefix,
      :honorific_suffix
    ]

    @type t :: %__MODULE__{
            id: String.t(),
            formatted: String.t() | nil,
            family_name: String.t(),
            given_name: String.t(),
            middle_name: String.t() | nil,
            honorific_prefix: String.t() | nil,
            honorific_suffix: String.t() | nil
          }

    def from_map(%{
          "id" => id,
          "formatted" => formatted,
          "familyName" => family_name,
          "givenName" => given_name,
          "middleName" => middle_name,
          "honorificPrefix" => honorific_prefix,
          "honorificSuffix" => honorific_suffix
        }) do
      %__MODULE__{
        id: id,
        formatted: formatted,
        family_name: family_name,
        given_name: given_name,
        middle_name: middle_name,
        honorific_prefix: honorific_prefix,
        honorific_suffix: honorific_suffix
      }
    end
  end

  defmodule Photo do
    @moduledoc "User photo"
    defstruct [:id, :value, :type]

    @type t :: %__MODULE__{
            id: String.t(),
            value: String.t(),
            type: String.t()
          }

    def from_map(%{"id" => id, "value" => value, "type" => type}) do
      %__MODULE__{id: id, value: value, type: type}
    end
  end

  defmodule Email do
    @moduledoc "User email"
    defstruct [:id, :value, :type]

    @type t :: %__MODULE__{
            id: String.t(),
            value: String.t(),
            type: String.t() | nil
          }

    def from_map(%{"id" => id, "value" => value, "type" => type}) do
      %__MODULE__{id: id, value: value, type: type}
    end
  end

  defmodule Verification do
    @moduledoc "Email verification status"
    defstruct [:id, :email, :verified, :created_at, :updated_at]

    @type t :: %__MODULE__{
            id: String.t(),
            email: String.t(),
            verified: boolean(),
            created_at: String.t(),
            updated_at: String.t()
          }

    def from_map(%{
          "id" => id,
          "email" => email,
          "verified" => verified,
          "createdAt" => created_at,
          "updatedAt" => updated_at
        }) do
      %__MODULE__{
        id: id,
        email: email,
        verified: verified,
        created_at: created_at,
        updated_at: updated_at
      }
    end
  end

  defmodule User do
    @moduledoc "User information"
    defstruct [
      :id,
      :external_id,
      :user_name,
      :display_name,
      :nick_name,
      :profile_url,
      :title,
      :user_type,
      :preferred_language,
      :locale,
      :timezone,
      :active,
      :names,
      :photos,
      :phone_numbers,
      :addresses,
      :emails,
      :verifications,
      :provider,
      :created_at,
      :updated_at,
      :environment_id
    ]

    @type t :: %__MODULE__{
            id: String.t(),
            external_id: String.t(),
            user_name: String.t(),
            display_name: String.t(),
            nick_name: String.t() | nil,
            profile_url: String.t() | nil,
            title: String.t() | nil,
            user_type: String.t() | nil,
            preferred_language: String.t() | nil,
            locale: String.t(),
            timezone: String.t() | nil,
            active: boolean(),
            names: Names.t(),
            photos: [Photo.t()],
            phone_numbers: [map()],
            addresses: [map()],
            emails: [Email.t()],
            verifications: [Verification.t()],
            provider: String.t(),
            created_at: String.t(),
            updated_at: String.t(),
            environment_id: String.t()
          }

    def from_map(%{
          "id" => id,
          "externalId" => external_id,
          "userName" => user_name,
          "displayName" => display_name,
          "nickName" => nick_name,
          "profileUrl" => profile_url,
          "title" => title,
          "userType" => user_type,
          "preferredLanguage" => preferred_language,
          "locale" => locale,
          "timezone" => timezone,
          "active" => active,
          "names" => names,
          "photos" => photos,
          "phoneNumbers" => phone_numbers,
          "addresses" => addresses,
          "emails" => emails,
          "verifications" => verifications,
          "provider" => provider,
          "createdAt" => created_at,
          "updatedAt" => updated_at,
          "environmentId" => environment_id
        }) do
      %__MODULE__{
        id: id,
        external_id: external_id,
        user_name: user_name,
        display_name: display_name,
        nick_name: nick_name,
        profile_url: profile_url,
        title: title,
        user_type: user_type,
        preferred_language: preferred_language,
        locale: locale,
        timezone: timezone,
        active: active,
        names: Names.from_map(names),
        photos: Enum.map(photos, &Photo.from_map/1),
        phone_numbers: phone_numbers,
        addresses: addresses,
        emails: Enum.map(emails, &Email.from_map/1),
        verifications: Enum.map(verifications, &Verification.from_map/1),
        provider: provider,
        created_at: created_at,
        updated_at: updated_at,
        environment_id: environment_id
      }
    end
  end

  defmodule UserInfoResponse do
    @moduledoc "Response from the /v1/userinfo endpoint"
    defstruct [:meta, :session, :user]

    @type t :: %__MODULE__{
            meta: Meta.t(),
            session: Session.t(),
            user: User.t()
          }

    def from_map(%{"meta" => meta, "session" => session, "user" => user}) do
      %__MODULE__{
        meta: Meta.from_map(meta),
        session: Session.from_map(session),
        user: User.from_map(user)
      }
    end
  end
end
