#
# == Class: nix - installs binary Nix package manager
#
# === Parameters:
#
# [*version*]
# String, default '1.7'. Specify the version of the Nix package manager to
# install.
#
# [*base_url*]
# String, default 'https://nixos.org/releases/nix'. Set the base URL to use
# for download URL. Useful if you want to host the Nix binaries within your
# datacenters.
#
# [*install_cwd*]
# String, default '/tmp'. Directory where you would like to download and
# extract the Nix binary distribution.
#
# [*download_file*]
# String, default 'nix-binary-tarball.tar.bz2'. Filename of the downloaded
# file regardless of version.
#
# [*extract_dir*]
# String, default 'nix-binary-tarball-unpack'. Subdirectory under
# *install_cwd* that the tarball will be extracted under.
#
# === Requires:
#
# None.
#
# === Examples
#
#    nix {
#      version  => '1.6',
#      base_url => 'https://my.internal.repo/nix',
#    }
#
class nix(
  $version        = '1.7',
  $base_url       = 'https://nixos.org/releases/nix',
  $install_cwd    = '/tmp',
  $download_file  = 'nix-binary-tarball.tar.bz2',
  $extract_dir    = 'nix-binary-tarball-unpack',
) {

  $system = $osfamily ? {
    'Darwin'  => 'x86_64-darwin',
    default   => "${architecture}-linux",
  }
  $url="${base_url}/nix-${version}/nix-${version}-${system}.tar.bz2"


  package { 'curl':
    ensure    => installed,
  }

  exec { "curl -sL -o ${install_cwd}/${download_file} ${url}":
    alias     => 'download-nix-tarball',
    cwd       => $install_cwd,
    require   => Package[curl],
    notify    => Exec['clean-tmp-tarball'],
  }

  exec { "rm -rf ${install_cwd}/${download_file}":
    alias     => 'clean-tmp-tarball',
    cwd       => $install_cwd,
  }

  file { "${install_cwd}/${extract_dir}":
    ensure    => directory,
    before    => Exec['extract-nix-binary-tarball'],
  }

  exec { "tar xf ${install_cwd}/${download_file} -C ${install_cwd}/${extract_dir}":
    alias     => 'extract-nix-binary-tarball',
    before    => Exec['run-nix-installer'],
    cwd       => $install_cwd,
  }

  exec { "${install_cwd}/${extract_dir}/*/install":
    alias     => 'run-nix-installer',
    notify    => Exec['clean-tmp-tarball'],
    cwd       => $install_cwd,
  }
}
