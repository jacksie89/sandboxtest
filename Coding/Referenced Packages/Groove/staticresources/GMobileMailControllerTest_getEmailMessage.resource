{
 "id": "149833ce2b464472",
 "threadId": "149833ce2b464472",
 "labelIds": [
  "INBOX",
  "IMPORTANT",
  "CATEGORY_PERSONAL"
 ],
 "snippet": "Hello World 1",
 "historyId": "688292",
 "payload": {
  "mimeType": "multipart/alternative",
  "filename": "",
  "headers": [
   {
    "name": "Delivered-To",
    "value": "mr.salesrep@my-company.com"
   },
   {
    "name": "Received",
    "value": "by 10.107.155.203 with SMTP id d194csp300619ioe;        Wed, 5 Nov 2014 19:54:06 -0800 (PST)"
   },
   {
    "name": "X-Received",
    "value": "by 10.107.153.135 with SMTP id b129mr1672326ioe.49.1415246046162;        Wed, 05 Nov 2014 19:54:06 -0800 (PST)"
   },
   {
    "name": "Return-Path",
    "value": "<customer@some-company.com>"
   },
   {
    "name": "Received",
    "value": "from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])        by mx.google.com with ESMTPS id ex7si8460988icc.20.2014.11.05.19.54.06        for <mr.salesrep@my-company.com>        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);        Wed, 05 Nov 2014 19:54:06 -0800 (PST)"
   },
   {
    "name": "Received-SPF",
    "value": "pass (google.com: domain of customer@some-company.com designates 2607:f8b0:4001:c03::234 as permitted sender) client-ip=2607:f8b0:4001:c03::234;"
   },
   {
    "name": "Authentication-Results",
    "value": "mx.google.com;       spf=pass (google.com: domain of customer@some-company.com designates 2607:f8b0:4001:c03::234 as permitted sender) smtp.mail=customer@some-company.com;       dkim=pass header.i=@gmail.com;       dmarc=pass (p=NONE dis=NONE) header.from=gmail.com"
   },
   {
    "name": "Received",
    "value": "by mail-ie0-f180.google.com with SMTP id y20so2119910ier.25        for <mr.salesrep@my-company.com>; Wed, 05 Nov 2014 19:54:05 -0800 (PST)"
   },
   {
    "name": "DKIM-Signature",
    "value": "v=1; a=rsa-sha256; c=relaxed/relaxed;        d=gmail.com; s=20120113;        h=mime-version:from:date:message-id:subject:to:content-type;        bh=wphWBEu8Z93XyWnJGW3pyV2F3POqTFKk9p7f+yI/l5w=;        b=KEH8eYTajPnETI9c+/J/OdTT0DE3rXBASUibsbAp8DVq5Vn3V0OInyZbbHFo2s3emj         jsxWadvsxR7V+NTwjDFE6pASaUsdUOBKiXtukfg9MAQiEjZ2Y4eZ8ohpHcr1b3fy8+IC         t6ktLLqgSuE7yNAF7uLoIqLsxBKRz+764Jreghz33onMFByfNOfJ5WOC23URu8VijzXW         HxE31/Oigh2wn/8iM9iscSIvEGp3yLT3o2cxhQ+aXxCrMVVNTAudPh6TeZMtLw86w+K6         kPJ6D+Yqlohi4ktqf4eBuKuZnyIyB+1178492ZXFVaV3kCnMm7XxUfX9bK2UVHfmpC5B         YMEw=="
   },
   {
    "name": "X-Received",
    "value": "by 10.50.79.232 with SMTP id m8mr36838349igx.11.1415246045823; Wed, 05 Nov 2014 19:54:05 -0800 (PST)"
   },
   {
    "name": "MIME-Version",
    "value": "1.0"
   },
   {
    "name": "Received",
    "value": "by 10.64.91.72 with HTTP; Wed, 5 Nov 2014 19:53:45 -0800 (PST)"
   },
   {
    "name": "From",
    "value": "Sascha Alexander Kerschhofer <customer@some-company.com>"
   },
   {
    "name": "Date",
    "value": "Wed, 5 Nov 2014 19:53:45 -0800"
   },
   {
    "name": "Message-ID",
    "value": "<CAORY+RMmJoOBCtnDw9z+BdiPDro_nkwm1PLKxCd2mTeUCdhJGQ@mail.gmail.com>"
   },
   {
    "name": "Subject",
    "value": "Hello World"
   },
   {
    "name": "To",
    "value": "Alex Kerschhofer <mr.salesrep@my-company.com>"
   },
   {
    "name": "Content-Type",
    "value": "multipart/alternative; boundary=089e013a0606d4fc74050728a5f1"
   }
  ],
  "body": {
   "size": 0
  },
  "parts": [
   {
    "partId": "0",
    "mimeType": "text/plain",
    "filename": "",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/plain; charset=UTF-8"
     }
    ],
    "body": {
     "size": 15,
     "data": "SGVsbG8gV29ybGQgMQ0K"
    }
   },
   {
    "partId": "1",
    "mimeType": "text/html",
    "filename": "",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/html; charset=UTF-8"
     }
    ],
    "body": {
     "size": 40,
     "data": "PGRpdiBkaXI9Imx0ciI-SGVsbG8gV29ybGQgMTxicj48L2Rpdj4NCg=="
    }
   }
  ]
 },
 "sizeEstimate": 2650
}