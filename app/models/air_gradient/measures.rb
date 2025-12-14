module AirGradient
  Measures = Data.define(
    :co2,
    :humidity,
    :pm01,
    :pm02,
    :pm10,
    :temp,
    :tvoc
  ) do
    PATH = "/measures/current"

    def self.current(serial_no:)
      Client
        .new(serial_no:)
        .get(PATH)
        .then { from_json(it.body) }
    end

    def self.from_json(json)
      new(
        co2: c_to_f(json["rco2"]),
        humidity: json["rhumCompensated"],
        pm01: json["pm01"],
        pm02: json["pm02Compensated"],
        pm10: json["pm10"],
        temp: json["atmpCompensated"],
        tvoc: json["tvocIndex"]
      )
    end

    def self.c_to_f(celsius)
      ((celsius * 9.0 / 5) + 32).round(1)
    end
  end
end
