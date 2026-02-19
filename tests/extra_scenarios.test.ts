
import { Cl, PrincipalCV } from "@stacks/transactions";
import { beforeEach, describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const alice = accounts.get("wallet_1")!;

const flasher = Cl.contractPrincipal(deployer, "flasher");
const maliciousRecipient = Cl.contractPrincipal(deployer, "mock-malicious-recipient");

describe("Flashloan Extra Scenarios", () => {
    beforeEach(() => {
        // Fund the flasher
        mintMockToken(1_000_000_000, flasher);
        simnet.transferSTX(100_000_000n, flasher.value.toString(), alice);
    });

    it("should fail when recipient does not repay STX (ERR_INSUFFICIENT_PAYBACK)", () => {
        const flashStxResult = simnet.callPublicFn(
            "flasher",
            "flash-stx",
            [Cl.uint(100_000), maliciousRecipient],
            alice
        );

        // Expect ERR_INSUFFICIENT_PAYBACK (u105)
        expect(flashStxResult.result).toBeErr(Cl.uint(105));
    });

    it("should fail when recipient does not repay SIP-010 (ERR_INSUFFICIENT_PAYBACK)", () => {
        const mockToken = Cl.contractPrincipal(deployer, "mock-token");

        const flashSip010Result = simnet.callPublicFn(
            "flasher",
            "flash-sip010",
            [mockToken, Cl.uint(100_000), maliciousRecipient],
            alice
        );

        // Expect ERR_INSUFFICIENT_PAYBACK (u105)
        expect(flashSip010Result.result).toBeErr(Cl.uint(105));
    });

    it("should allow 0 amount flash loan (if valid)", () => {
        // 0 amount -> 0 fee -> 0 repayment expected
        const mockRecipient = Cl.contractPrincipal(deployer, "mock-flash-recipient");

        // Initialize mock recipient
        simnet.callPublicFn(
            "mock-flash-recipient",
            "set-flashloans",
            [flasher],
            deployer
        );

        const result = simnet.callPublicFn(
            "flasher",
            "flash-stx",
            [Cl.uint(0), mockRecipient],
            alice
        );

        expect(result.result).toBeOk(Cl.bool(true));
    });
});

function mintMockToken(amount: number, to: PrincipalCV) {
    return simnet.callPublicFn(
        "mock-token",
        "mint",
        [Cl.uint(amount), to],
        deployer
    );
}
