# Getting Started

A plain-language guide to running this lab yourself, start to finish. No prior
experience with virtual machines assumed. If a term is new, it's explained the
first time it appears.

## What you're about to build

This project builds a small, fake company network made of several **virtual
machines** (VMs) — whole computers that run as software windows on your real PC.
One VM pretends to be the company's main server, one holds files, one is a
security monitoring system, and one is the "attacker." You'll then play out a
realistic break-in, watch the security system miss it, fix the weaknesses, and
watch it catch the attack the second time.

Everything runs in a sealed bubble on your own machine. The fake company network
can only talk to itself — it cannot reach your real home network or the internet
in a way that puts you at risk.

## Before you start — what you need

- **A personal Windows PC** (not a work-managed one — those often block this kind
  of software).
- **At least 16 GB of RAM** (32 GB is comfortable). The VMs borrow memory from
  your PC while they run and give it back when stopped.
- **About 60 GB of free disk space.**
- **A few hours and a stable internet connection** for the first build (it
  downloads several gigabytes).

## Step 1 — Install two free programs

1. **VirtualBox** — the software that runs the virtual machines.
   Download the "Windows hosts" version from <https://www.virtualbox.org>.
2. **Vagrant** — the tool that builds the VMs automatically from the instructions
   in this project, so you don't have to set each one up by hand.
   Download the Windows (AMD64) version from
   <https://developer.hashicorp.com/vagrant/install>.

Install both with their default options. **Then close any open terminal windows
and open a fresh one** — new programs only become usable in terminals opened
afterward.

Check they installed correctly by typing:

```
vagrant --version
```

A version number means you're good. If it says "not recognized," restart your PC
once and try again.

## Step 2 — Add one small plugin

The Windows VMs need to restart themselves during setup. This plugin lets the
build handle that automatically:

```
vagrant plugin install vagrant-reload
```

## Step 3 — Protect the attack tools from your antivirus

Later steps use real security-testing tools that antivirus software often
quarantines. Tell Windows Defender to leave this project's folder alone:
open **Windows Security → Virus & threat protection → Manage settings →
Exclusions → Add an exclusion → Folder**, and choose the project folder.

(This only affects that one folder, nothing else on your PC.)

## Step 4 — Build the lab, one machine at a time

Open a terminal, go into the project's `lab` folder, and bring the machines up in
this order. Each command may take a while the first time — that's normal.

```
cd path\to\vendor-credential-compromise-lab\lab

vagrant up siem01     # the security monitoring system (build this first)
vagrant up dc01       # the main company server
vagrant up fs01       # the file server
```

**What to expect while they build:**
- The first machine downloads a base image — mostly a waiting game.
- `dc01` is the slowest. Partway through it will **restart itself** and the screen
  may go quiet for several minutes. This is expected, not a crash.
- You might get a Windows firewall pop-up — click **Allow**.

**How to know each one worked:** after `siem01`, open a web browser to
<https://127.0.0.1:8443>. Your browser will warn the page isn't private (because
the lab uses its own security certificate) — click through it. You should reach a
login page. Log in as `admin`; the password is saved in the file
`lab\.secrets\wazuh-passwords.txt`.

Once `dc01` and `fs01` are built, log back into that dashboard and look for them
listed as **active agents** — that confirms the monitoring is watching them.

## Step 5 — Save a clean checkpoint

Before attacking anything, take a snapshot so you can rewind and try again:

```
vagrant snapshot save baseline
```

Rewind any time with `vagrant snapshot restore baseline`.

## Step 6 — Run the attack, then the defense

From here, follow the guides in the project folders, in order:

1. **`attack/runbook.md`** — walks you through the break-in step by step, and
   tells you what the monitoring system should (and shouldn't) notice.
2. **`harden/README.md`** — applies the fixes that close each weakness.
3. Re-run the attack and record what's now blocked or caught. That before-and-after
   comparison is the whole point of the project.

Write down what you see as you go in `docs/lab-notes/` — those notes become the
evidence that you did the work.

## Turning the lab off and on

- Stop the VMs (free up your PC's memory): `vagrant halt`
- Start them again later: `vagrant up`
- Delete everything when you're finished: `vagrant destroy -f`

## If something goes wrong

- Check a machine's state with `vagrant status`.
- Re-run a failed setup safely with `vagrant provision <name>` (e.g.
  `vagrant provision dc01`) — the scripts are written to be repeatable.
- Watch what a VM is actually doing by opening the VirtualBox app and
  double-clicking the machine. Press the **right Ctrl** key to free your mouse
  from the VM window afterward.

## A note on safety

This lab is intentionally insecure and contains only fake, clearly-labeled data.
Keep it on its own isolated network (the default). Never change the network
setting from "internal" to "bridged," and never reuse the lab's passwords
anywhere else.
