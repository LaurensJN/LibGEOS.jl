using BinDeps
@BinDeps.setup

function version_check(name, handle)
    fptr = Libdl.dlsym(handle, :GEOSversion)
    versionptr = ccall(fptr,Cstring,())
    # looks like "3.4.2-CAPI-1.8.2 r3921"
    versionstring = unsafe_string(versionptr)
    # looks like "3.4.2"
    versiononly = first(split(versionstring, '-', limit=2))
    geosversion = convert(VersionNumber, versiononly)
    geosversion >= version
end

libgeos = library_dependency("libgeos",aliases=["libgeos_c", "libgeos_c-1"], validate=version_check)

const version = v"3.6.1"

provides(Sources, URI("http://download.osgeo.org/geos/geos-$(version).tar.bz2"), [libgeos], os = :Unix)
provides(BuildProcess,Autotools(libtarget = "capi/.libs/libgeos_c."*Libdl.dlext),libgeos)
# provides(AptGet,"libgeos-dev", libgeos)
# TODO: provides(Yum,"libgeos-dev", libgeos)
# TODO: provides(Pacman,"libgeos-dev", libgeos)

if is_windows()
    using WinRPM
    push!(WinRPM.sources, "http://download.opensuse.org/repositories/home:yeesian/openSUSE_Leap_42.2")
    WinRPM.update()
    provides(WinRPM.RPM, "libgeos", [libgeos], os = :Windows)
end

if is_apple()
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    provides(Homebrew.HB, "geos", libgeos, os = :Darwin)
end

@BinDeps.install Dict(:libgeos => :libgeos)
