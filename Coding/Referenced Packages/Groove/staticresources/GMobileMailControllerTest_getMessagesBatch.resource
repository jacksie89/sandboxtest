--batch_kedpl8fqDfw_AAiZp6ywTpE
Content-Type: application/http

HTTP/1.1 200 OK
ETag: "yEJ6cH_j8v1sh2SNo0PjBwIT__w/QrarkC2HKnG-szsPdh4_EPZomw8"
Content-Type: application/json; charset=UTF-8
Date: Sun, 09 Nov 2014 19:30:50 GMT
Expires: Sun, 09 Nov 2014 19:30:50 GMT
Cache-Control: private, max-age=0
Content-Length: 3983

{ 
 "id": "1498d0017868df53",
 "threadId": "1498d0017868df53",
 "labelIds": [
  "INBOX",
  "IMPORTANT",
  "CATEGORY_PERSONAL"
 ],
 "snippet": "Can you please send me a quote? Thanks",
 "payload": {
  "mimeType": "multipart/alternative",
  "headers": [
   {
    "name": "Delivered-To",
    "value": "alex@grooveapp.com"
   },
   {
    "name": "Received",
    "value": "by 10.107.155.203 with SMTP id d194csp257950ioe;        Fri, 7 Nov 2014 17:23:53 -0800 (PST)"
   },
   {
    "name": "X-Received",
    "value": "by 10.107.34.9 with SMTP id i9mr4792639ioi.33.1415409833715;        Fri, 07 Nov 2014 17:23:53 -0800 (PST)"
   },
   {
    "name": "Return-Path",
    "value": "\u003ccontact@some-company.com\u003e"
   },
   {
    "name": "Received",
    "value": "from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])        by mx.google.com with ESMTPS id nk7si17351117icb.61.2014.11.07.17.23.53        for \u003calex@grooveapp.com\u003e        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);        Fri, 07 Nov 2014 17:23:53 -0800 (PST)"
   },
   {
    "name": "Received-SPF",
    "value": "pass (google.com: domain of contact@some-company.com designates 2607:f8b0:4001:c05::236 as permitted sender) client-ip=2607:f8b0:4001:c05::236;"
   },
   {
    "name": "Authentication-Results",
    "value": "mx.google.com;       spf=pass (google.com: domain of contact@some-company.com designates 2607:f8b0:4001:c05::236 as permitted sender) smtp.mail=contact@some-company.com;       dkim=pass header.i=@gmail.com;       dmarc=pass (p=NONE dis=NONE) header.from=gmail.com"
   },
   {
    "name": "Received",
    "value": "by mail-ig0-f182.google.com with SMTP id hn18so6394689igb.15        for \u003calex@grooveapp.com\u003e; Fri, 07 Nov 2014 17:23:53 -0800 (PST)"
   },
   {
    "name": "DKIM-Signature",
    "value": "v=1; a=rsa-sha256; c=relaxed/relaxed;        d=gmail.com; s=20120113;        h=mime-version:from:date:message-id:subject:to:content-type;        bh=olkJtmBnb2Lqoe/B8b1z6gYUm9DtvhF3/aN8OTuAxwU=;        b=k0tn4gqHDGIKQtdUfx0ua/OCFYbHZx0gXqVdsu9tj93SnJE/5g2JbMBpH9VDda05q9         +bDq+czL6zldiM+zNYouR+Nl8aFTNERNJNqTEEbuCinAJU8IjjLn41RbSeWnIJfjtdm5         8UAEXC+7kd8wThofGTtOd+IxhlZ88kJFw4tv/gn141tf24luO7605N/buMEhgFHTjA/6         tFP4M8KinZY+fAWgSt514TRp76QI+dHXlpDNfVpp6untN8GEmX3h1BhbWCYYhdzAhQWQ         VDHel2b+JQZl17aKz33aY1gVtclRfhjYd/FVlJa4zIlSspYhDps4d3yK4L4yVHMU40zs         y1LA=="
   },
   {
    "name": "X-Received",
    "value": "by 10.51.16.36 with SMTP id ft4mr8154240igd.19.1415409833591; Fri, 07 Nov 2014 17:23:53 -0800 (PST)"
   },
   {
    "name": "MIME-Version",
    "value": "1.0"
   },
   {
    "name": "Received",
    "value": "by 10.64.91.72 with HTTP; Fri, 7 Nov 2014 17:23:33 -0800 (PST)"
   },
   {
    "name": "From",
    "value": "Mr. Somebody \u003csomebody@some-company.com\u003e"
   },
   {
    "name": "Date",
    "value": "Fri, 7 Nov 2014 17:23:33 -0800"
   },
   {
    "name": "Message-ID",
    "value": "\u003cCAORY+RNq4K3Zk46DXh5vrd7tCkBxqtx22pL40w_MkkNYAfpExw@mail.gmail.com\u003e"
   },
   {
    "name": "Subject",
    "value": "Bucket 1.1 email"
   },
   {
    "name": "To",
    "value": "Mrs. Salesrep \u003cmr.salesrep@my-company.com\u003e"
   },
   {
    "name": "Content-Type",
    "value": "multipart/alternative; boundary=001a1134aace57ce9205074ec855"
   }
  ],
  "body": {
   "size": 0
  },
  "parts": [
   {
    "mimeType": "text/plain",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/plain; charset=UTF-8"
     }
    ],
    "body": {
     "size": 40,
     "data": "Q2FuIHlvdSBwbGVhc2Ugc2VuZCBtZSBhIHF1b3RlPyBUaGFua3MNCg=="
    }
   },
   {
    "mimeType": "text/html",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/html; charset=UTF-8"
     }
    ],
    "body": {
     "size": 61,
     "data": "PGRpdiBkaXI9Imx0ciI-Q2FuIHlvdSBwbGVhc2Ugc2VuZCBtZSBhIHF1b3RlPyBUaGFua3M8L2Rpdj4NCg=="
    }
   }
  ]
 }
}

--batch_kedpl8fqDfw_AAiZp6ywTpE
Content-Type: application/http

HTTP/1.1 200 OK
ETag: "yEJ6cH_j8v1sh2SNo0PjBwIT__w/uwszIvFdHmiUU8AopdbUmcpPeGU"
Content-Type: application/json; charset=UTF-8
Date: Sun, 09 Nov 2014 19:30:50 GMT
Expires: Sun, 09 Nov 2014 19:30:50 GMT
Cache-Control: private, max-age=0
Content-Length: 1699

{
 "id": "1498d0de8179ab58",
 "threadId": "1498d0ccf8b99a48",
 "labelIds": [
  "SENT",
  "UNREAD",
  "IMPORTANT"
 ],
 "snippet": "Hello. Here is your quote",
 "payload": {
  "mimeType": "multipart/alternative",
  "headers": [
   {
    "name": "MIME-Version",
    "value": "1.0"
   },
   {
    "name": "Received",
    "value": "by 10.107.155.203 with HTTP; Fri, 7 Nov 2014 17:27:38 -0800 (PST)"
   },
   {
    "name": "X-Originating-IP",
    "value": "[99.113.34.235]"
   },
   {
    "name": "Date",
    "value": "Fri, 7 Nov 2014 17:27:38 -0800"
   },
   {
    "name": "Delivered-To",
    "value": "alex@grooveapp.com"
   },
   {
    "name": "Message-ID",
    "value": "\u003cCAGJ+yDs2Lbg6h3BUVt2t=1xdoFG9dQoc9-P79eERZmdTR-yt6Q@mail.gmail.com\u003e"
   },
   {
    "name": "Subject",
    "value": "Bucket 1.2 email"
   },
   {
    "name": "From",
    "value": "Mrs. Salesrep \u003cmr.salesrep@my-company.com\u003e"
   },
   {
    "name": "To",
    "value": "Mr. Contact \u003ccontact@some-company.com\u003e"
   },
   {
    "name": "Content-Type",
    "value": "multipart/alternative; boundary=047d7b2e0a6dc5556d05074ed56a"
   }
  ],
  "body": {
   "size": 0
  },
  "parts": [
   {
    "mimeType": "text/plain",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/plain; charset=UTF-8"
     }
    ],
    "body": {
     "size": 27,
     "data": "SGVsbG8uIEhlcmUgaXMgeW91ciBxdW90ZQ0K"
    }
   },
   {
    "mimeType": "text/html",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/html; charset=UTF-8"
     }
    ],
    "body": {
     "size": 50,
     "data": "PGRpdiBkaXI9Imx0ciI-SGVsbG8uIEhlcmUgaXMgeW91ciBxdW90ZQ0KPC9kaXY-DQo="
    }
   }
  ]
 }
}

--batch_kedpl8fqDfw_AAiZp6ywTpE
Content-Type: application/http

HTTP/1.1 200 OK
ETag: "yEJ6cH_j8v1sh2SNo0PjBwIT__w/WI40OaYhWXPXrnjKwWLWDT7xLLg"
Content-Type: application/json; charset=UTF-8
Date: Sun, 09 Nov 2014 19:30:50 GMT
Expires: Sun, 09 Nov 2014 19:30:50 GMT
Cache-Control: private, max-age=0
Content-Length: 5069

{
 "id": "1498d047c07e985d",
 "threadId": "1498d0386ae03a72",
 "labelIds": [
  "INBOX",
  "IMPORTANT",
  "CATEGORY_PERSONAL"
 ],
 "snippet": "Thanks, I will look into it. 2014-11-07 17:27 GMT-08:00 Mrs. Salesrep &lt;mr.salesrep@my-company.com&gt;:",
 "payload": {
  "mimeType": "multipart/alternative",
  "headers": [
   {
    "name": "Delivered-To",
    "value": "alex@grooveapp.com"
   },
   {
    "name": "Received",
    "value": "by 10.107.155.203 with SMTP id d194csp258259ioe;        Fri, 7 Nov 2014 17:28:42 -0800 (PST)"
   },
   {
    "name": "X-Received",
    "value": "by 10.107.11.129 with SMTP id 1mr17043154iol.18.1415410122161;        Fri, 07 Nov 2014 17:28:42 -0800 (PST)"
   },
   {
    "name": "Return-Path",
    "value": "\u003ccontact@some-company.com\u003e"
   },
   {
    "name": "Received",
    "value": "from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])        by mx.google.com with ESMTPS id mb6si17295269icc.105.2014.11.07.17.28.42        for \u003calex@grooveapp.com\u003e        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);        Fri, 07 Nov 2014 17:28:42 -0800 (PST)"
   },
   {
    "name": "Received-SPF",
    "value": "pass (google.com: domain of contact@some-company.com designates 2607:f8b0:4001:c03::22e as permitted sender) client-ip=2607:f8b0:4001:c03::22e;"
   },
   {
    "name": "Authentication-Results",
    "value": "mx.google.com;       spf=pass (google.com: domain of contact@some-company.com designates 2607:f8b0:4001:c03::22e as permitted sender) smtp.mail=contact@some-company.com;       dkim=pass header.i=@gmail.com;       dmarc=pass (p=NONE dis=NONE) header.from=gmail.com"
   },
   {
    "name": "Received",
    "value": "by mail-ie0-f174.google.com with SMTP id x19so6314894ier.33        for \u003calex@grooveapp.com\u003e; Fri, 07 Nov 2014 17:28:42 -0800 (PST)"
   },
   {
    "name": "DKIM-Signature",
    "value": "v=1; a=rsa-sha256; c=relaxed/relaxed;        d=gmail.com; s=20120113;        h=mime-version:in-reply-to:references:from:date:message-id:subject:to         :content-type;        bh=6w73PPOztUjU4i3z0h9WdFJZZTSyP6lq+wZLwM+OKro=;        b=EFpqTGrsEUPzUAkV4VGG2cxiuI13P2mL7jDHszMYoGEb3n0pKYwg9pCA0Fx5blP0xd         IyB7NlhXaWlN+BTgufkJpqKGxucYmubXyqgmLkN5ZB8y6VvFwNBlMwhl6O7PITOCgbkL         XVZCz9go5RdvsFGQ/hja3KsdX7iPAq7/msxz2VsMdqC5VZETvupTIx0cq9ujSDaR0mi+         0JMQ1DAAg48F5MgdS2yUCyxHKwAZyjXHsRin6Asa1Y+eP7aJPRyTdXXzfLrQS5liG2MN         k2+WnsrJ2b6VRX4/RC2xW4/TmVxvSAoCoXzE4gphfdqwYXP2iuP8bUrEyew5oiVFQgh7         DjEA=="
   },
   {
    "name": "X-Received",
    "value": "by 10.51.16.162 with SMTP id fx2mr8275514igd.11.1415410122042; Fri, 07 Nov 2014 17:28:42 -0800 (PST)"
   },
   {
    "name": "MIME-Version",
    "value": "1.0"
   },
   {
    "name": "Received",
    "value": "by 10.64.91.72 with HTTP; Fri, 7 Nov 2014 17:28:20 -0800 (PST)"
   },
   {
    "name": "In-Reply-To",
    "value": "\u003cCAGJ+yDs2Lbg6h3BUVt2t=1xdoFG9dQoc9-P79eERZmdTR-yt6Q@mail.gmail.com\u003e"
   },
   {
    "name": "References",
    "value": "\u003cCAGJ+yDs2Lbg6h3BUVt2t=1xdoFG9dQoc9-P79eERZmdTR-yt6Q@mail.gmail.com\u003e"
   },
   {
    "name": "From",
    "value": "Mr. Contact \u003ccontact@some-company.com\u003e"
   },
   {
    "name": "Date",
    "value": "Fri, 7 Nov 2014 17:28:20 -0800"
   },
   {
    "name": "Message-ID",
    "value": "\u003cCAORY+RPU5fnD7cDc6EipLD0HVccy99S1dsL1DtKEq6o++Fdnaw@mail.gmail.com\u003e"
   },
   {
    "name": "Subject",
    "value": "Re: Bucket 1.2 email"
   },
   {
    "name": "To",
    "value": "Mrs. Salesrep \u003cmr.salesrep@my-company.com\u003e"
   },
   {
    "name": "Content-Type",
    "value": "multipart/alternative; boundary=001a1135f844893bc505074ed980"
   }
  ],
  "body": {
   "size": 0
  },
  "parts": [
   {
    "mimeType": "text/plain",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/plain; charset=UTF-8"
     }
    ],
    "body": {
     "size": 133,
     "data": "VGhhbmtzLCBJIHdpbGwgbG9vayBpbnRvIGl0Lg0KDQoyMDE0LTExLTA3IDE3OjI3IEdNVC0wODowMCBBbGV4IEtlcnNjaGhvZmVyIDxhbGV4QGdyb292ZWFwcC5jb20-Og0KDQo-IEhlbGxvLiBIZXJlIGlzIHlvdXIgcXVvdGUNCj4NCg=="
    }
   },
   {
    "mimeType": "text/html",
    "headers": [
     {
      "name": "Content-Type",
      "value": "text/html; charset=UTF-8"
     },
     {
      "name": "Content-Transfer-Encoding",
      "value": "quoted-printable"
     }
    ],
    "body": {
     "size": 440,
     "data": "PGRpdiBkaXI9Imx0ciI-VGhhbmtzLCBJIHdpbGwgbG9vayBpbnRvIGl0LjxkaXYgY2xhc3M9ImdtYWlsX2V4dHJhIj48YnI-PGRpdiBjbGFzcz0iZ21haWxfcXVvdGUiPjIwMTQtMTEtMDcgMTc6MjcgR01ULTA4OjAwIEFsZXggS2Vyc2NoaG9mZXIgPHNwYW4gZGlyPSJsdHIiPiZsdDs8YSBocmVmPSJtYWlsdG86YWxleEBncm9vdmVhcHAuY29tIiB0YXJnZXQ9Il9ibGFuayI-YWxleEBncm9vdmVhcHAuY29tPC9hPiZndDs8L3NwYW4-Ojxicj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2IGRpcj0ibHRyIj5IZWxsby4gSGVyZSBpcyB5b3VyIHF1b3RlDQo8L2Rpdj4NCjwvYmxvY2txdW90ZT48L2Rpdj48YnI-PC9kaXY-PC9kaXY-DQo="
    }
   }
  ]
 }
}

--batch_kedpl8fqDfw_AAiZp6ywTpE--