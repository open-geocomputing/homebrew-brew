class G2s < Formula
  desc "Toolbox for geostatistical simulations"
  homepage "https://gaia-unil.github.io/G2S/"
  version "0.98.015"
  url "https://github.com/GAIA-UNIL/G2S/archive/8fe43a4728a9db4d7311070e93dd98b3fc18a395.tar.gz"
  sha256 "eead5560668b5ad0764a7d16690dc279d8e195e899c1b33b9fce5e1462a7b8a4"
  license "GPL-3.0-only"
  
  # Add dependencies
  depends_on "cppzmq"
  depends_on "fftw"
  depends_on "jsoncpp"
  depends_on "libomp"
  depends_on "zeromq"
  uses_from_macos "curl"
  uses_from_macos "zlib"

  def install
    cd "build" do
      # Run "make c++ -j"
      system "make", "c++", "-j", "CXXFLAGS=-Xclang -fopenmp -I#{Formula["fftw"].opt_include}", \
          "LIB_PATH=-L#{Formula["fftw"].opt_lib} -L#{Formula["libomp"].opt_lib} -lomp"
    end

    # Copy g2s_server and other from the c++-build folder to the brew bin folder
    bin.install "build/g2s-package/g2s-brew/g2s"
    libexec.install "build/c++-build/g2s_server"
    libexec.install "build/c++-build/echo"
    libexec.install "build/c++-build/qs"
    libexec.install "build/c++-build/nds"
    libexec.install "build/c++-build/ds-l"
    libexec.install "build/c++-build/errorTest"
    libexec.install "build/c++-build/auto_qs"
    libexec.install "build/algosName.config"

    # bash_completion.install "build/g2s-package/g2s-brew/g2s-completion.sh"
    # zsh_completion.install "build/g2s-package/g2s-brew/g2s-completion.zsh"
    # fish_completion.install "build/g2s-package/g2s-brew/g2s-completion.fish"
  end

  service do
    run [opt_bin/"g2s", "server", "-kod"]
    keep_alive true
  end

  test do
    pid = fork do
      exec bin/"g2s", "server"
    end
    sleep 3
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
