class MinioMc < Formula
  desc "Replacement for ls, cp and other commands for object storage"
  homepage "https://github.com/minio/mc"
  url "https://github.com/minio/mc.git",
      :tag      => "RELEASE.2019-08-21T19-59-10Z",
      :revision => "89d30e9aa28883e416f193219db2c3367489dafd"
  version "20190821195910"

  bottle do
    cellar :any_skip_relocation
    sha256 "8dfafe89de9f709db12c8e273697c54231ac64543ca443c8f94894181002005f" => :mojave
    sha256 "f48c95c01f1d79ebde84d5e8c38216ab1551b91764512820e9b6f12f66d73723" => :high_sierra
    sha256 "f76fa5fb767709836283fe937ab5207f03e29512fc51f5f06850d1593359b27e" => :sierra
    sha256 "cd50437701a30cfdb3a1e607cc450ce40a8cd07d97c7bd9e5936fe69bcd01340" => :x86_64_linux
  end

  depends_on "go" => :build

  conflicts_with "midnight-commander", :because => "Both install a `mc` binary"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    src = buildpath/"src/github.com/minio/mc"
    src.install buildpath.children
    src.cd do
      if build.head?
        system "go", "build", "-o", buildpath/"mc"
      else
        minio_release = `git tag --points-at HEAD`.chomp
        minio_version = minio_release.gsub(/RELEASE\./, "").chomp.gsub(/T(\d+)\-(\d+)\-(\d+)Z/, 'T\1:\2:\3Z')
        minio_commit = `git rev-parse HEAD`.chomp
        proj = "github.com/minio/mc"

        system "go", "build", "-o", buildpath/"mc", "-ldflags", <<~EOS
          -X #{proj}/cmd.Version=#{minio_version}
          -X #{proj}/cmd.ReleaseTag=#{minio_release}
          -X #{proj}/cmd.CommitID=#{minio_commit}
        EOS
      end
    end

    bin.install buildpath/"mc"
    prefix.install_metafiles
  end

  test do
    system bin/"mc", "mb", testpath/"test"
    assert_predicate testpath/"test", :exist?
  end
end
