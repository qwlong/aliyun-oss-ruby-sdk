# -*- encoding: utf-8 -*-

module Aliyun
  module OSS

    ##
    # OSS服务的客户端，用于获取bucket列表，连接到指定的bucket。
    # @example 创建Client
    #   endpoint = 'oss-cn-hangzhou.oss.aliyuncs.com'
    #   client = Client.new(endpoint, 'access_key_id', 'access_key_secret')
    #   buckets = client.list_buckets
    #   bucket = client.get_bucket('my-bucket')
    # @example 连接到Bucket
    #   bucket = Client.connect_to_bucket('my-bucket', endpoint, 'access_key_id', 'access_key_secret')
    class Client

      include Logging

      # 构造OSS client，用于操作buckets。
      # @param opts [Hash] 构造Client时的参数选项
      # @option opts [String] :endpoint [必填]OSS服务的地址，可以是以
      #  oss.aliyuncs.com的标准域名，也可以是用户绑定的域名
      # @option opts [String] :access_key_id [必填]用户的ACCESS KEY ID
      # @option opts [String] :access_key_secret [必填]用户的ACCESS
      #  KEY SECRET
      # @option opts [Boolean] :cname [可选] 指定endpoint是否是用户绑
      #  定的域名
      # @example 标准endpoint
      #   oss-cn-hangzhou.aliyuncs.com
      #   oss-cn-beijing.aliyuncs.com
      # @example 用户绑定的域名
      #   my-domain.com
      #   foo.bar.com
      def initialize(opts)
        missing_args = [:endpoint, :access_key_id, :access_key_secret] - opts.keys
        raise ClientError.new("Missing arguments: #{missing_args.join(', ')}") \
                             unless missing_args.empty?

        Config.set_endpoint(opts[:endpoint], opts[:cname] == true)
        Config.set_credentials(opts[:access_key_id], opts[:access_key_secret])
      end

      # 列出当前所有的bucket
      # @param opts [Hash] 查询选项
      # @option opts [String] :prefix 如果设置，则只返回以它为前缀的bucket
      # @return [Enumerator<Bucket>] Bucket的迭代器
      def list_buckets(opts = {})
        raise ClientError.new("Cannot list buckets for a CNAME endpoint") \
                             if Config.get(:cname)
        Iterator::Buckets.new(opts).to_enum
      end

      # 创建一个bucket
      # @param name [String] Bucket名字
      # @param opts [Hash] 创建Bucket的属性（可选）
      # @option opts [:location] [String] 指定bucket所在的区域，默认为oss-cn-hangzhou
      def create_bucket(name, opts = {})
        Protocol.create_bucket(name, opts)
      end

      # 删除一个bucket
      # @param name [String] Bucket名字
      # @note 如果要删除的Bucket不为空（包含有object），则删除会失败
      def delete_bucket(name)
        Protocol.delete_bucket(name)
      end

      # 获取一个Bucket对象，用于操作bucket中的objects。
      # @param name [String] Bucket名字
      # @return [Bucket] Bucket对象
      def get_bucket(name)
        Bucket.new(:name => name)
      end

    end # Client
  end # OSS
end # Aliyun
