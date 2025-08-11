class Pgpi < Formula
  desc "Postgres Private Investigator"
  homepage "https://github.com/neondatabase-labs/pgpi"
  url "https://github.com/neondatabase-labs/pgpi/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "93f1924284c1f8d5834690fd53b1e315e0366bf96bab503f17a833765acea8aa"
  license "Apache-2.0"

  depends_on "ruby"

  def install
    # copy script from release tarball (there are no dependencies)
    bin.install "pgpi"

    # rewrite shebang to use Homebrew-supplied Ruby
    ruby_rewrite_info = Utils::Shebang::RewriteInfo.new(
      %r{^#!/usr/bin/env ruby$},
      "#!/usr/bin/env ruby".length,
      "#{Formula["ruby"].opt_bin}/ruby",
    )
    rewrite_shebang ruby_rewrite_info, "#{bin}/pgpi"
  end

  test do
    port = 54545
    pid = spawn bin/"pgpi", "--client-listen-port", port.to_s
    sleep 1 # takes a moment to be ready to listen
    conn = TCPSocket.new "127.0.0.1", port
    conn.write "\x00\x00\x00\x08\x04\xd2\x16\x2f" # send SSLRequest
    response = conn.read 1 # read response
    assert_equal "S", response # expect "S": SSL is supported
    Process.kill "SIGTERM", pid
  end
end
