# 1.RabbitMQ简介
RabbitMQ是流行的开源消息队列系统，用erlang语言开发。RabbitMQ是AMQP的实现。RabbitMQ支持AJAX。用于在分布式系统存储转发消息，在易用性、扩展性、高可用性等方面表现给力。

# 2.基本概念
	Producer将消息发送到Exchange，Exchange通过绑定+Routing KEY，将消息路由到对应的一个或多个Queue中，消费者消费一个或多个Queue。

## 2.1 Queue
	RabbitMQ的内部对象，用于存储信息。RabbitMQ的消息只能存储在Queue中。多个消费者可以同时订阅同一个Queue，这是Queue的消息是平均分摊到多个消费者进行处理，而不是每个消费者都接收到所有消息并处理。
## 2.2 Message Acknowledgement（消息回执）
	实际应用中，可能会发生消费者收到Queue的消息，但是还没处理完毕就宕机的情况，这种情况下，就会导致信息丢失，为了避免这种情况发生，我们可以要求消费者在消费完消息后发送一个回执给RabbitMQ，RabbitMQ收到消息回执后，才将消息从Queue中移除。如果RabbitMQ没有收到回执，并检测到消费者的RabbitMQ链接断开，则RabbitMQ会将该消息发送给其他消费者进行处理。一个消费者处理消息时间不管多长也不会导致该消息被发送后再发给其他消费者，除非它与RabbitMQ链接断开。

	**PS：**这里可能会发生开发人员处理完业务逻辑后，没有发送回执，这将会导致消息堆积；消费者重启后可能会重复消费这些信息。

## 2.3 Message durability（消息持久化）
	我们可以将Queue和Message都设置成可持久化的，这样就保证绝大多数情况下我们的RabbitMQ消息不会丢失。只会丢失一些还没来得及持久化的数据，如果要管理这些数据，则需要使用事务
## 2.4 Prefetch count（预取数据）
	如果有多个消费者同时订阅同一个Quque中的消息，Quque中的消息会被平摊给多个消费者。这时如果每个消息的处理时间不同，就有可能导致某些消费者一直很忙，而另一些消费者很快处理完手头上工作，并一直空闲的情况下。我们可以通过设置prefetch count=1，则Quque每次给每个消费者发送一条消息；消费者处理完这条消息后Quque会再给消费者发送一条消息。
## 2.5 Exchange（交换器）
	生产者将消息发送到Exchange（交换器，下图中X），Exchange将消息路由到一个或者多个Quque中或者丢弃。
## 2.6 routing key
	生产者在将消息发送给Exchange的时候，一般会指定一个routing key，来指定这个路由规则，而这个routing key需要与 Exchange Type 与binding key 联合使用才能最终生效。
在Exchange Tpye 与binding key 固定的情况下(在正常使用情况下，这些内容都是配置好的)，我们的生产者就可以在发送消息给Exchange的时候，通过指定routing key 来指定消息流的流向哪里。
## 2.7 binding
	RabbitMQ 中通过Binding 将Exchange 与Quque关联起来，这样RabbitMQ就知道如何正确地将消息路由到指定的Quque了
## 2.8 Exchange Type
	RabbitMQ常用的Exchange Tpye 有fanout、direct、topic、headers这四种
### 2.8.1 fanout（分列）
	fanout类型的Exchange路由规则非常简单，它会把所有发送到该Exchange的消息路由到所有与它绑定的Queue中。
### 2.8.2 direct（重定向）
	direct类型的Exchange路由规则也很简单，它会把消息路由到那些binding key与routing key完全匹配的Queue中。
### 2.8.3 topic（主题）
	topic类型的Exchange在匹配规则上进行了扩展，它与direct类型的Exchage相似，也是将消息路由到binding key与routing key相匹配的Queue中，但这里的匹配规则有些不同，它约定：。类似于正则表达式匹配
### 2.8.4 headers
	根据发送的消息内容中的headers属性进行匹配。在绑定Queue与Exchange时指定一组键值对；当消息发送到Exchange时，RabbitMQ会取到该消息的headers（也是一个键值对的形式），对比其中的键值对是否完全匹配Queue与Exchange绑定时指定的键值对；如果完全匹配则消息会路由到该Queue，否则不会路由到该Queue。
	**这个类型的，很少会用到**


