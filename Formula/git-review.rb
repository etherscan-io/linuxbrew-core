class GitReview < Formula
  desc "Submit git branches to gerrit for review"
  homepage "https://git.openstack.org/cgit/openstack-infra/git-review"
  url "https://files.pythonhosted.org/packages/70/c5/e2930e1017516a9cbe777581767785650b7e8ee89580ba00cabdf992e058/git-review-1.26.0.tar.gz"
  sha256 "487c3c1d7cc81d02b303a1245e432579f683695c827ad454685b3953f70f0b94"
  head "https://git.openstack.org/openstack-infra/git-review.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "5187b16328f105d195c58b4a978f8232b98b47e9cb91557f15ce4ca439a50385" => :high_sierra
    sha256 "5187b16328f105d195c58b4a978f8232b98b47e9cb91557f15ce4ca439a50385" => :sierra
    sha256 "661bd93e96795bb2ef4a0260fc441fd6eb437bb109e9f4353a577db638617c58" => :el_capitan
    sha256 "cdbb1fb8034daf2d52730b711b84306ab43a9c3d5b7a96c678fb08fb9a3e3220" => :x86_64_linux
  end

  depends_on "python@2"

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/23/3f/8be01c50ed24a4bd6b8da799839066ce0288f66f5e11f0367323467f0cbc/certifi-2017.11.5.tar.gz"
    sha256 "5ec74291ca1136b40f0379e1128ff80e866597e4e2c1e755739a913bbc3613c0"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"
    sha256 "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/f4/bd/0467d62790828c23c47fc1dfa1b1f052b24efdf5290f071c7a91d0d82fd3/idna-2.6.tar.gz"
    sha256 "2c6a5de3089009e3da7c5dde64a141dbc8551d5b7f6cf4ed7c2568d0cc520a8f"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/b0/e1/eab4fc3752e3d240468a8c0b284607899d2fbfb236a56b7377a329aa8d09/requests-2.18.4.tar.gz"
    sha256 "9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/ee/11/7c59620aceedcc1ef65e156cc5ce5a24ef87be4107c2b74458464e437a5d/urllib3-1.22.tar.gz"
    sha256 "cc44da8e1145637334317feebd728bd869a35285b93cbb4cca2577da7e62db4f"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", "#{libexec}/vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", "#{libexec}/lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    man1.install gzip("git-review.1")

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "git", "init"
    system "git", "remote", "add", "gerrit", "https://github.com/Homebrew/homebrew.github.io"
    (testpath/".git/hooks/commit-msg").write "# empty - make git-review happy"
    (testpath/"foo").write "test file"
    system "git", "add", "foo"
    system "git", "commit", "-m", "test"
    system "#{bin}/git-review", "--dry-run"
  end
end
