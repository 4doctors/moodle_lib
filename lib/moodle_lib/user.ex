defmodule MoodleLib.User do
  defstruct firstname: nil,
            lastname: nil,
            password: nil,
            createpassword: nil,
            email: nil,
            auth: nil,
            idnumber: nil,
            lang: nil,
            calendartype: nil,
            theme: nil,
            timezone: nil,
            mailformat: nil,
            description: nil,
            city: nil,
            country: nil,
            firstnamephonetic: nil,
            lastnamephonetic: nil,
            middlename: nil,
            alternatename: nil,
            customfields: %{}
end
