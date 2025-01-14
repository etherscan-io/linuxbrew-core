class Opa < Formula
  desc "Open source, general-purpose policy engine"
  homepage "https://www.openpolicyagent.org"
  url "https://github.com/open-policy-agent/opa/archive/v0.13.3.tar.gz"
  sha256 "1288c2687b5b8fd106dca78df96be7b022322b3465a384a0c7545748969cdd5c"

  bottle do
    cellar :any_skip_relocation
    sha256 "739a12287279ed4d5765b2573b33f383e64a264b36d8dfd784006c490d74f2f4" => :mojave
    sha256 "6807cc9a6df74306ef978716fa7f3929151c1aafb1e47c7d59267c44facb1089" => :high_sierra
    sha256 "42deabb98be39ced00d89dc6a32590c71cad4994fe39a720b4d56b2507d9b532" => :sierra
    sha256 "00dc145cb83a6e6001dbfa68333d753ffe22255cf90fbdcc5227ced172c938d0" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/open-policy-agent/opa").install buildpath.children

    cd "src/github.com/open-policy-agent/opa" do
      system "go", "build", "-o", bin/"opa", "-installsuffix", "static",
                   "-ldflags",
                   "-X github.com/open-policy-agent/opa/version.Version=#{version}"
      prefix.install_metafiles
    end
  end

  test do
    output = shell_output("#{bin}/opa eval -f pretty '[x, 2] = [1, y]' 2>&1")
    assert_equal "+---+---+\n| x | y |\n+---+---+\n| 1 | 2 |\n+---+---+\n", output
    assert_match "Version: #{version}", shell_output("#{bin}/opa version 2>&1")
  end
end
