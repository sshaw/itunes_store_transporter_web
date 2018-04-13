<style>
  td { padding: 6px 12px; }
</style>

# iTunes Store Transporter: GUI - Help

## Table of Contents

* [API](#api)
* [Notification Templates](#notification-templates)
* [Job Hooks](#job-hooks)
* [More Help](#more-help)

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
	  "execute": null,
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
 	  "execute": null,
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
* `execute` - program to execute on job completion (currently only supported for uploads)
* `disable_notification` - email notification's are enabled/disabled for the job

#### Errors

Responses with a non-HTTP 2XX status are considered errors.
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

The property `base` (not shown) refers to the request itself and not a specific property.

#### Priorities

Certain jobs accept a priority, this specifies the priority in which they'll be processed by `itmsworker`.
Valid priorities are: `normal`, `high`, `low`, `next`.

A priority of `next` will put the job at the front of the queue (well, assuming there isn't another
job with `next` priority in front of it).

### Endpoints

#### Job

Retrieve a job by its ID.

* Endpoint: `/api/jobs/ID`
* Method: `GET`

`ID` must be replaced with a job id from the Transporter GUI.

##### Response

See [Response Objects](#response-objects).

##### Sample

	curl -H 'content-type: application/json' 'http://localhost:3000/api/jobs/132'

#### Providers

Create a job to retrieve the metadata for a previously uploaded package.

* Endpoint: `/api/lookup`
* Method: `POST`

##### Request

* `package_id`: The type of identifier used to lookup the metadata, must be `vendor_id` or `apple_id`
* `package_id_value`: The identifier
* `account_id`: The Transporter GUI ID of the account to use to request the package's
* `priority`: Optional, job priority, defaults to `"normal"`. See [Job Priorities](#priorities).

##### Response

See [Response Objects](#response-objects).

##### Sample

	curl -H 'content-type: application/json' -XPOST 'http://localhost:3000/api/lookup' -d '{
	  "package_id": "vendor_id",
	  "package_id_value": "X123999",
	  "account_id": 12
	}'

#### Providers

Create a job that will retrieve a list of providers for which `account_id` has permission to deliver content.

* Endpoint: `/api/providers`
* Method: `POST`

##### Request

* `account_id`: The Transporter GUI ID of the account to use to request the package's
* `priority`: Optional, job priority, defaults to `"normal"`. See [Job Priorities](#priorities).

##### Response

See [Response Objects](#response-objects).

##### Sample

	curl -H 'content-type: application/json' -XPOST 'http://localhost:3000/api/providers' -d '{
	  "account_id": 12
	}'

#### Schema

Create a job to retrieve a metadata schema.

* Endpoint: `/api/schema`
* Method: `POST`

##### Request

* `version_name`: Type of schema, either `film` or `tv`.
* `version_number`: Schema version
* `type`: Schema type, either `strict` or `transitional`
* `account_id`: The Transporter GUI ID of the account to use to request the package's status
* `priority`: Optional, job priority, defaults to `"normal"`. See [Job Priorities](#priorities).

##### Response

See [Response Objects](#response-objects).

#### Sample

	curl -H 'content-type: application/json' -XPOST 'http://localhost:3000/api/schema' -d '{
	  "version_name": "film",
	  "version_number": "5.9",
	  "type": "strict",
	  "account_id": 12
	}'

#### Search

Job search.

* Endpoint: `/api/jobs/search`
* Method: `GET`

##### Request

All parameters are optional.

* `page`: Page number to retrieve
* `per_page`: Number of jobs displayed per page
* `account_id`: The Transporter GUI ID of the account the job is associated with
* `priority`: Job priority, see [Job Priority](#priority)
* `target`: This varies based on the job's type. For an upload job this is the package name, for a status job this is the vendor id, etc...
* `state`: Job's state, one of: `queued`, `running`, `success`, `failure`
* `type`: Job type, one of: `lookup`, `providers`, `schema`, `status`, `upload`, `verify`
* `updated_at_from`: Date the package was last updated or, if `updated_at_to` is given, the start of a date range, given in `YYYY-MM-DD` format.
* `updated_at_to`: End date of the date range started by `updated_at_from`,  given in `YYYY-MM-DD` format.

Results can be ordered, the order must be given in `order=COLUMN:DIR` format, where `DIR` is either `asc` or `desc` (ascending or descending)
and `COLUMN` must be one of:

* `account`
* `priority`
* `target`
* `type`
* `state`
* `created_at`
* `updated_at`

##### Response


	{
	  "page": {
		"number": 1,
		"size": 2,
		"count": 14
	  },
	  "jobs": [

	  ]
	}

`jobs` contains an array of [job objects](#job).

##### Sample

    curl  -XGET 'http://localhost:3000/api/jobs/search?type=upload&updated_at_from=2016-01-01&updated_at_to=2016-01-14'

And the results:

	{
	  "page": {
		"number": 1,
		"size": 10,
		"count": 1
	  },
	  "jobs": [
		{
		  "id": 47,
		  "state": "success",
		  "options": {
			"package": "/Users/sshaw/Desktop/123123123X.itmsp",
			"batch": false,
			"rate": "",
			"transport": "Aspera",
			"delete": false,
			"success": "",
			"failure": "",
			"username": "sshaw",
			"password": "s3kreeeeT!",
			"shortname": ""
		  },
		  "result": "Package Summary:\n\n    1 package was uploaded successfully:\n    \t/Users/sshaw/Desktop/WITH_MD.itmsp\n",
	  	  "execute": null,
		  "exceptions": null,
		  "created_at": "2016-01-12T05:29:55.878Z",
		  "updated_at": "2016-01-12T05:34:54.372Z",
		  "priority": "normal",
		  "account_id": 1,
		  "disable_notification": false,
		  "type": "upload"
		},
		{
		  "id": 20,
		  "state": "failure",
		  "options": {
			"package": "foo.itmsp",
			"username": "sshaw",
			"password": "s3kreeeeT!",
			"shortname": "",
			"delete": null,
			"batch": null
		  },
		  "result": null,
	  	  "execute": null,
		  "exceptions": "option invalid: package; dir 'foo.itmsp' does not exist",
		  "created_at": "2016-01-13T18:53:40.446Z",
		  "updated_at": "2016-01-13T05:34:47.825Z",
		  "priority": "normal",
		  "account_id": 1,
		  "disable_notification": false,
		  "type": "upload"
		}
	  ]
	}


#### Status

Create a job to check an previous upload's status.

* Endpoint: `/api/status`
* Method: `POST`

##### Request

* `vendor_id`: ID of the package to perform a status request on
* `account_id`: The Transporter GUI ID of the account to use to request the package's status
* `priority`: Optional, job priority, defaults to `"normal"`. See [Job Priorities](#priorities).

##### Response

See [Response Objects](#response-objects).

##### Sample

	curl -H 'content-type: application/json' -XPOST 'http://localhost:3000/api/status' -d '{
	  "vendor_id": "X123999",
	  "account_id": 12
	}'

#### Upload

Create an upload package job.

* Endpoint: `/api/upload`
* Method: `POST`

##### Request

All paths must be accessible by the worker process.

* `package`: Absolute path of the package to upload
* `disable_notification`: optional, disable email notifications for this job only
* `rate`: Optional, transfer rate in kbps
* `batch`: Optional, batch upload, defaults to `false`
* `execute`: Optional, program to execute after the job completes, must be accessible by the worker process. See [Job Hooks](#job-hooks).
* `success`: Optional, absolute path of a directory to move package to if the upload succeeds
* `failure`: Optional, absolute path of a directory to move package to if the upload fails
* `priority`: Optional, job priority, defaults to `"normal"`. See [Job Priorities](#priorities).
* `account_id`: The Transporter GUI ID of the account to use to upload the package
* `delete`: Optional, defaults to `false`:
* `transport`: Optional, defaults to ITMSTrasnporter's default

##### Response

See [Response Objects](#response-objects).

##### Sample

	curl -H 'content-type: application/json' -XPOST 'http://localhost:3000/api/upload' -d '{
	  "package": "/path/to/package.itmsp",
	  "account_id": 12,
	  "transport": "Aspera"
	}'

#### Verify

Create a package verification job.

* Endpoint: `/api/verify`
* Method: `POST`

##### Request

* `package`: Absolute path of the package to upload, must be accessible by the worker process
* `account_id`: The Transporter GUI ID of the account to use to request the package's status
* `batch`: Optional, batch verification, defaults to `false`
* `verify_assets`: Optional, verify assets (normally only the metadata is verified), defaults to `false`
* `priority`: Optional, job priority, defaults to `"normal"`. See [Job Priorities](#priorities).

##### Response

See [Response Objects](#response-objects).

#### Sample

	curl -H 'content-type: application/json' -XPOST 'http://localhost:3000/api/verify' -d '{
	  "package": "/path/to/package.itmsp",
	  "account_id": 12
	}'

## Notification Templates

*Notifications are currently only supported for upload jobs.*

The subject and message fields of notifications can contain [ERB](https://en.wikipedia.org/wiki/ERuby).
See the below table for the supported variables.

The variables **are not** Ruby instance variables, so you must not prefix them with the `@`.

I.e., do this:
```erb
Job number: <%= job_id %>
```

Not this:
```erb
Job number: <%= @job_id %>
```

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
`account_itc_provider` | `String` | iTunes Connect provider name of the package's iTunes Connect account (can be `nil`)
`email_to` | `Array` | Recipient email addresses
`email_from` | `String` | Sender's email address
`email_reply_to` | `String` | Reply to email address (can be `nil`)

## Job Hooks

*Jobs hooks are currently only supported for upload jobs.*

Job hooks allow one to specify a command to be executed when a job completes.
Information about the job is made available via the following environment variables:

Variable | Description
---------|------------------------
`ITMS_JOB_ID` | Job id
`ITMS_JOB_TARGET` | Job target, varies based on the job type
`ITMS_JOB_PACKAGE_PATH` | Absolute path to the package, if the job contains one (can be empty)
`ITMS_JOB_TYPE` | The type of job, currently always `upload`
`ITMS_JOB_STATE` | Job state, either `success` or `failure`
`ITMS_JOB_CREATED` | Time the job was created, given in `YYYY-MM-DD HH:MM:SS ±ZONE` format (24 hour clock)
`ITMS_JOB_COMPLETED` | Time the job finished, given in `YYYY-MM-DD HH:MM:SS ±ZONE` format (24 hour clock)
`ITMS_ACCOUNT_USERNAME` | Username of the package's iTunes Connect account
`ITMS_ACCOUNT_SHORTNAME` | Shortname (encoding house user) of the package's iTunes Connect account (can be empty)
`ITMS_ACCOUNT_ITC_PROVIDER` | iTunes Connect provider name (can be empty)

Job hooks with a non-zero exit code are considered an error.

## More Help

If you've encountered a bug please [open an issue](https://github.com/sshaw/itunes_store_transporter_web/issues).

For commercial support email [help@screenstaring.com](mailto:help@screenstaring.com?subject=Transporter%20GUI).

---

Made by [ScreenStaring](http://screenstaring.com)
