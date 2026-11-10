---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]]"
status: new
tags: [generated]
---
# Pub/Sub Messaging
**In one line:** Publishers send messages to a topic; every subscriber gets its own copy. Senders and receivers never need to know about each other.

**In plain words:** When an order is placed, billing, inventory and analytics all need to know. Instead of the order service calling each one (and breaking if one is down), it posts one message to an `orders.created` topic. Each team has its own subscription and reads at its own pace. Adding a new consumer means adding a subscription, not changing the publisher.

**Terms**
| Term | Means |
|---|---|
| Publisher | service that sends messages |
| Topic | named channel messages are sent to (durable, partitioned) |
| Subscription | one consumer's independent queue on a topic |
| Subscriber | service that receives messages |
| Asynchronous | sender doesn't wait for receivers |
| Decoupled | components can change or fail independently |

**Key points**
- Example: order-service and checkout-service → topic `orders.created` → billing, inventory and analytics subscriptions.
- Services: Google Cloud Pub/Sub, AWS SNS/SQS, Kafka.
- Enables real-time streaming between independent systems.
- "Use messaging to decouple systems" (Week 2 summary).

**Memorize vs. look up:** Memorize publisher → topic → subscription → subscriber, and "each gets its own copy".

Related: [[Batch vs Streaming]], [[Serverless Computing]], [[Object Storage]]

*Note title uses "Pub-Sub" because a slash can't appear in a file name.*
