# S3Policy

Generate your [S3 upload policies](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTForms.html) in Swift.

For signing the policy you can use https://github.com/darkFunction/S3SignerAWS

## Example use

Here we create the encoded policy and sign it using S3SignerAWS.

```swift
    import S3SignerAWS

    ...

    let timestamp = Date().iso8601(compact: true)
    let signer = S3Signer(accessKey: <awsAccessKey>, secretKey: <awsSecretKey>, region: <region>)
    let credential = "\(<awsAccessKey>)/\(signer.credentialScope(timeStampShort: timestamp.short))"
        
    let policy = S3Policy(
        expiration: <expiration>,
        conditions: [
            .exact(.bucket, <bucket>),
            .startsWith(.key, <path>),
            .exact(.acl, <acl>),
            .startsWith(.contentType, "image/"),
            .contentLength(0...<maxBytes>),
            .exact(.xAmzAlgorithm, SigningAlgorithm.hmacSha256.rawValue),
            .exact(.xAmzCredential, credential),
            .exact(.xAmzDate, timestamp.full)
        ]
    )

    let policyBase64 = try policy.json().base64()
    let policySignature = try signer.createSignature(stringToSign: policyBase64, timeStampShort: timestamp.short)
```



