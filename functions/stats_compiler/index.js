const fetch = require('node-fetch');

exports.handler = async function(event) {
  console.log("EVENT: \n" + JSON.stringify(event));

  const logData = await fetch(`https://logs.tf/json/${event.log.logname}`).then((res) => res.json());

  console.log(logData)

  return logData;
};
