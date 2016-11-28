<style>
  td { padding: 6px 12px; }
</style>

# iTunes Store Transporter: GUI - Help

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
