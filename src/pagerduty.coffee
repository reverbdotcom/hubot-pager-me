pagerDutyUserId        = process.env.HUBOT_PAGERDUTY_USER_ID
pagerDutyApiKey        = process.env.HUBOT_PAGERDUTY_API_KEY
pagerDutySubdomain     = process.env.HUBOT_PAGERDUTY_SUBDOMAIN
pagerDutyBaseUrl       = "https://#{pagerDutySubdomain}.pagerduty.com/api/v1"
pagerDutyServiceApiKey = process.env.HUBOT_PAGERDUTY_SERVICE_API_KEY
pagerDutyServices      = process.env.HUBOT_PAGERDUTY_SERVICES
pagerRoom              = process.env.HUBOT_PAGERDUTY_ROOM
# Webhook listener endpoint. Set it to whatever URL you want, and make sure it matches your pagerduty service settings
pagerEndpoint          = process.env.HUBOT_PAGERDUTY_ENDPOINT || "/hook"
pagerNoop              = process.env.HUBOT_PAGERDUTY_NOOP
pagerNoop               = false if pagerNoop is "false" or pagerNoop  is "off"

module.exports = (robot) ->
  pagerDutyGet = (msg, url, query, cb) ->
    if missingEnvironmentForApi(msg)
      return

    if pagerDutyServices? && url.match /\/incidents/
      query['service'] = pagerDutyServices

    auth = "Token token=#{pagerDutyApiKey}"
    msg.http(pagerDutyBaseUrl + url)
      .query(query)
      .headers(Authorization: auth, Accept: 'application/json')
      .get() (err, res, body) ->
        if err?
          return robot.emit 'error', err, msg
        json_body = null
        switch res.statusCode
          when 200 then json_body = JSON.parse(body)
          else
            console.log res.statusCode
            console.log body
            json_body = null
        cb json_body

  missingEnvironmentForApi = (msg) ->
    missingAnything = false
    unless pagerDutySubdomain?
      msg.send "PagerDuty Subdomain is missing:  Ensure that HUBOT_PAGERDUTY_SUBDOMAIN is set."
      missingAnything |= true
    unless pagerDutyApiKey?
      msg.send "PagerDuty API Key is missing:  Ensure that HUBOT_PAGERDUTY_API_KEY is set."
      missingAnything |= true
    missingAnything

  return pagerDutyGet: pagerDutyGet
