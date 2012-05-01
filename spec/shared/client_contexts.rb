shared_context 'connection opts' do
  let(:connection_opts) { { :thread => :per_callback } }
  let(:connection_host) { "localhost:#{ZK_TEST_PORT}" }
  let(:connection_args) { [connection_host, connection_opts] }
end

shared_context 'threaded client connection' do
  include_context 'connection opts'

  before do
    @connection_string = "localhost:#{ZK_TEST_PORT}"
    @base_path = '/zktests'
    @zk = ZK::Client::Threaded.new(*connection_args).tap { |z| wait_until { z.connected? } }
    @zk.on_exception { |e| raise e }
    @zk.rm_rf(@base_path)
  end

  after do
    if @zk.closed?
      ZK.open(*connection_args) { |z| z.rm_rf(@base_path) }
    else
      @zk.rm_rf(@base_path)
      @zk.close!
      wait_until(2) { @zk.closed? }
    end
  end
end


