module AirGradient
  MEASURES_ATTRS = %i[
    co2
    humidity
    nox
    pm01
    pm02
    pm10
    temp
    tvoc
  ]

  class Measures < Data.define(*MEASURES_ATTRS)
    PATH = "/measures/current"

    def self.current(url:)
      Client
        .new(url:)
        .get(PATH)
        .then { from_json(it.body) }
    end

    def self.from_json(json)
      new(
        co2: json["rco2"],
        humidity: json["rhumCompensated"],
        nox: json["noxIndex"],
        pm01: json["pm01"],
        pm02: json["pm02Compensated"],
        pm10: json["pm10"],
        temp: c_to_f(json["atmpCompensated"]),
        tvoc: json["tvocIndex"]
      )
    end

    def self.c_to_f(celsius)
      ((celsius * 9.0 / 5) + 32).round(1)
    end
  end
end
