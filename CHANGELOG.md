# Changelog

All notable changes to this Kernel 6.18+ port are documented here.

## [1.0.0] - 2026-01-23

### Added
- Complete port to Linux Kernel 6.18.3+
- Automated installation script (`install.sh`)
- Manual patch application script (`apply-patches.sh`)
- Comprehensive README with troubleshooting guide
- Technical documentation (TECHNICAL.md)
- GPL v2 license

### Fixed
- **Critical**: Fixed kthread_stop crash on module unload (Patch 01)
  - Added thread state validation before calling kthread_stop()
  - Prevents kernel panic when threads already terminated
  
- **Critical**: Fixed message handler null pointer crash (Patch 02)
  - Added proper bounds checking for message handler arrays
  - Allows NULL handlers for CFM (confirmation) messages
  - Resolved command timeout issues during initialization
  
- **Critical**: Fixed MAC address generation (Patch 03)
  - Implemented fallback random MAC generation when eFuse empty
  - Uses get_random_bytes() for proper randomization
  
- **Critical**: Fixed memory allocation stubs (Patch 04)
  - Implemented real aicwf_prealloc_txq_alloc() with kzalloc
  - Prevents NULL pointer crashes in TX queue allocation
  
- **Minor**: Removed deprecated MODULE_IMPORT_NS (Patch 05)
  - Fixed link errors with Kernel 6.18+ build system
  
- **Config**: Disabled CONFIG_PREALLOC_TXQ (Patch 06)
  - Workaround for allocation stability issues

### Changed
- Based on Kiborgik/aic8800dc-linux-patched fork instead of official Radxa repo
- Updated build system for GCC 15.2.1 compatibility
- Enhanced error handling throughout driver

### Tested On
- Fedora 43 (Kernel 6.18.3-200.fc43.x86_64)
- GCC 15.2.1-5 (Red Hat)
- AIC8800DC USB Wi-Fi Adapter (VID:PID a69c:8800)

### Known Issues
- Bluetooth functionality not extensively tested
- Monitor mode not verified
- CONFIG_PREALLOC_TXQ disabled (needs further investigation)

### Performance
- 2.4GHz: ~150 Mbps throughput, 20-30ms latency
- 5GHz: ~400 Mbps throughput, 15-25ms latency
- Stable operation >24 hours continuous use
- Suspend/resume working correctly

---

## [Unreleased]

### Future Improvements
- Enable CONFIG_PREALLOC_TXQ with proper fixes
- Test on other distributions (Debian, Ubuntu, Arch)
- Comprehensive Bluetooth testing
- DKMS auto-build integration
- Consider upstream submission

---

**Version Format**: [Major.Minor.Patch]  
**Date Format**: YYYY-MM-DD
