<style>
  td { padding: 6px 12px; }
</style>

# iTunes Store Transporter: GUI - Help

## Table of Contents

* [API](#api)
* [Notification Templates](#notification-templates)

## API

All responses have a content type of `application/json`.

### Response Objects

#### Job

Represents a Transporter GUI job. Here's an example for a queued, upload job:

	{
	  "id": 112,
      "type": "upload"
	  "state": "queued",
	  "options": {
		"package": "/some/package.itmsp",
		"delete": false,
		"username": "fofinha123",
		"password": "shhhhh!",
		"shortname": "sshaw",
		"batch": null
	  },
	  "result": null,
	  "exceptions": null,
	  "created_at": "2016-11-19T20:01:07.373Z",
	  "updated_at": "2016-11-19T20:01:07.373Z",
	  "priority": "normal",
	  "account_id": 12,
	  "disable_notification": false
	}

Here's one for a failed verify job:

	{
	  "id": 105,
	  "type": "verify",
	  "state": "failure",
	  "options": {
		"package": "/Users/sshaw/Desktop/982345323555.itmsp",
		"batch": true,
		"verify_assets": false,
		"username": "user@example.com",
		"password": "123",
		"shortname": "shorty"
	  },
	  "result": null,
	  "exceptions": "Feature is missing a checksum (5011), Playlist already exits for this UPC (3005), Bad chapter timecode (4009), Preorder date must be before available date (4019)",
	  "created_at": "2016-09-04T00:54:24.205Z",
	  "updated_at": "2016-09-25T02:48:06.575Z",
	  "priority": "normal",
	  "account_id": 15,
	  "disable_notification": false
	}

##### Properties

* `id` - job's id
* `type` - one of `lookup`, `providers`, `schema`, `status`, `upload`, `verify`, `version`
* `state` - one of `queued`, `running`, `success`, `failure`
* `options` - arguments passed to `iTMSTransporter`, this varies based on the job's type, see Endpoints below
* `result` - the results of a successful job, this varies based on the job type
* `exceptions` - why the job failed
* `disable_notification` - email notification's are enabled/disabled for the job


#### Errors

Error responses with a non-HTTP 2XX status are considered errors.
With the exception of a HTTP 422 (see below) error responses contain a single property `error`,
whose value contains the error message:

	{"error":"Not found"}

With HTTP 422 response, each property is a request property and its value is an array that contains
the reasons why the give property was invalid. For example:

	{
	  "account_id": [
		"unknown"
	  ],
	  "package": [
		"must end with \".itmsp\""
	  ]
	}

### Endpoints

#### Upload

Create an upload package job

* Endpoint: `/api/upload`
* Method: `POST`

#### Request

##### Properties

* `package`: Absolute path of the package to upload, this path must be accessible by the worker process
* `disable_notification`: optional, disable email notifications for this job only
* `rate`: optional, transfer rate in kbps
* `batch` optional, defaults to `false`:
* `success` optional:
* `failure` optional:
* `priority` optional, defaults to `"Normal"`
* `account_id`: The Transporter GUI ID of the account to use to upload the package
* `delete` optional, defaults to `false`:
* `transport` optional, defaults to ITMSTrasnporter's default

### Verify

* Endpoint: `/api/verify`
* Method: `POST`

### Status

* Endpoint: `/api/status`
* Method: `POST`

...


## Notification Templates

*Notifications are currently only supported for upload jobs.*

The subject and message fields of notifications can contain [ERB](https://en.wikipedia.org/wiki/ERuby).
See the below table for the supported variables.

Variable | Type      | Description
---------|-----------|----------------
`job_id` | `String` | Job id
`job_target` | `String` | Job target, varies based on the job type
`job_package_path` | `String` | Absolute path to the package, if the job contains one
`job_type` | `String` | The type of job
`job_state` | `String` | Job state
`job_created` | `Time` | Time the job was created
`job_completed` | `Time` | Time the job finished
`account_username` | `String` | Username of the package's iTunes Connect account
`account_shortname` | `String` | Shortname of the package's iTunes Connect account (can be `nil`)
`email_to` | `Array` | Recipient email addresses
`email_from` | `String` | Sender's email address
`email_reply_to` | `String` | Reply to email address (can be `nil`)
