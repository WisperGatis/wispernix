# wispernix

Flakes 기반 NixOS 설정 저장소입니다. 시스템 모듈, 사용자 홈 설정(Home Manager), 데스크톱 환경, 테마용 설정 파일을 한곳에서 관리합니다.

> 🌐 [English version below](#wispernix-english)

---

## 구조

| 경로 | 설명 |
| --- | --- |
| `flake.nix` | 입력(inputs)과 `nixosConfigurations.nixos` 정의 |
| `configuration.nix` | 최상위 시스템 설정 진입점 |
| `hardware-configuration.nix` | 하드웨어 자동 생성 설정 |
| `flake/modules.nix` | 추가 NixOS 모듈과 overlay (`nixpkgs.overlays`) |
| `modules/` | 시스템 모듈: 부팅, 네트워크, 오디오, 그래픽, 디스플레이 매니저, 폰트, 게임, 가상화, 스토리지, 사용자 등 |
| `home/` | Home Manager 설정: 셸, 터미널, 편집기, 멀티플렉서, 앱, 스크립트 |
| `config/` | 실제 적용되는 dotfile: `fish`, `starship`, `nvim`, `niri`, `sway`, `mango`, `labwc`, `umbriel`, 커서 테마 |
| `obscura-vpn/` | Obscura VPN NixOS 모듈 (별도 flake) |

## 주요 구성 요소

- **데스크톱:** niri, sway, mango(mangowm), labwc
- **셸과 UI:** dms(dux shell), caelestia shell, noctalia greeter
- **브라우저:** Helium, Zen, Waterfox 등 (`flake/modules.nix`와 `modules/`에서 설정)
- **AI 도구:** Claude Desktop, Codex Desktop, Claude Code
- **게임:** Steam 관련 모듈(Millennium), `modules/gaming.nix`
- **프롬프트:** starship 설정은 `config/starship`에서 관리

## 사용법

저장소 최상단에서 빌드하고 적용합니다.

```bash
# 빌드만 확인
nix build '.#nixosConfigurations."nixos".config.system.build.toplevel' --no-link

# 시스템에 적용
sudo nixos-rebuild switch --flake .#nixos
```

flake 입력을 갱신할 때는 다음을 사용합니다.

```bash
nix flake update
```

## 알려진 문제

- **openssl 1.1.1w 빌드 실패:** `test_afalg`가 AF_ALG 커널 지원을 요구합니다. 빌드 샌드박스에서는 이 지원이 없어 실패하므로, `flake/modules.nix`에서 `openssl_1_1`의 테스트를 건너뛰도록 했습니다. 커널에서 AF_ALG를 켜면 이 우회는 필요하지 않습니다.
- **`nixpkgs.config.permittedInsecurePackages`:** `modules/nix.nix`에 명시된 패키지는 보안 경고를 알고 허용한 것입니다.

---

<a id="wispernix-english"></a>

# wispernix (English)

A NixOS configuration repository built on flakes. It manages system modules, user environment settings (Home Manager), desktop environments, and theme files in one place.

> 🌐 [한국어 버전은 위에 있습니다](#wispernix)

---

## Layout

| Path | Description |
| --- | --- |
| `flake.nix` | Inputs and the `nixosConfigurations.nixos` definition |
| `configuration.nix` | Top-level system entry point |
| `hardware-configuration.nix` | Auto-generated hardware settings |
| `flake/modules.nix` | Extra NixOS modules and overlays (`nixpkgs.overlays`) |
| `modules/` | System modules: boot, network, audio, graphics, display manager, fonts, gaming, virtualisation, storage, users, and more |
| `home/` | Home Manager config: shell, terminals, editors, multiplexers, apps, scripts |
| `config/` | Dotfiles that get applied: `fish`, `starship`, `nvim`, `niri`, `sway`, `mango`, `labwc`, `umbriel`, cursor themes |
| `obscura-vpn/` | Obscura VPN NixOS module (separate flake) |

## Main components

- **Desktops:** niri, sway, mango (mangowm), labwc
- **Shells and UI:** dms (dux shell), caelestia shell, noctalia greeter
- **Browsers:** Helium, Zen, Waterfox, and others (configured in `flake/modules.nix` and `modules/`)
- **AI tools:** Claude Desktop, Codex Desktop, Claude Code
- **Gaming:** Steam-related module (Millennium) and `modules/gaming.nix`
- **Prompt:** the starship config lives in `config/starship`

## Usage

Build and apply from the repository root:

```bash
# Build only, to check
nix build '.#nixosConfigurations."nixos".config.system.build.toplevel' --no-link

# Apply to the system
sudo nixos-rebuild switch --flake .#nixos
```

To update flake inputs:

```bash
nix flake update
```

## Known issues

- **openssl 1.1.1w build failure:** `test_afalg` requires AF_ALG kernel support. The build sandbox does not provide it, so the test fails. `flake/modules.nix` disables the test suite for `openssl_1_1` as a workaround. Enabling AF_ALG in the kernel makes this workaround unnecessary.
- **`nixpkgs.config.permittedInsecurePackages`:** the packages listed in `modules/nix.nix` are allowed on purpose, with their insecurity known.
