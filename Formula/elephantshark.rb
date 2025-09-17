class Elephantshark < Formula
  desc "Postgres network traffic monitor"
  homepage "https://github.com/neondatabase-labs/elephantshark"
  url "https://github.com/neondatabase-labs/elephantshark/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "d82a7e1cacb1d7a57a97436bfd060e8ea8dd7d8eb7a9850ade057cc848f39509"
  license "Apache-2.0"

  depends_on "ruby"

  def install
    # copy script from release tarball (there are no dependencies)
    bin.install "elephantshark"

    # rewrite shebang to use Homebrew-supplied Ruby
    ruby_rewrite_info = Utils::Shebang::RewriteInfo.new(
      %r{^#!/usr/bin/env ruby$},
      "#!/usr/bin/env ruby".length,
      "#{Formula["ruby"].opt_bin}/ruby",
    )
    rewrite_shebang ruby_rewrite_info, "#{bin}/elephantshark"
  end

  test do
    port = 54545
    pid = spawn bin/"elephantshark", "--client-listen-port", port.to_s
    sleep 1 # takes a moment to be ready to listen
    conn = TCPSocket.new "127.0.0.1", port
    conn.write "\x00\x00\x00\x08\x04\xd2\x16\x2f" # send SSLRequest
    response = conn.read 1 # read response
    assert_equal "S", response # expect "S": SSL is supported
    Process.kill "SIGTERM", pid
  end
end
