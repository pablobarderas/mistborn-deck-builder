extends RefCounted
## Modifica únicamente los saldos del candidato de autoridad.

const MAX_INT: int = 9223372036854775807


static func apply(balances: Dictionary, debit_key: String, cost: int, credit_key: String, gain: int) -> bool:
	if debit_key == credit_key or cost <= 0 or gain <= 0:
		return false
	var debit_balance: Variant = balances.get(debit_key)
	var credit_balance: Variant = balances.get(credit_key)
	if not (debit_balance is int) or not (credit_balance is int):
		return false
	if debit_balance < cost or credit_balance < 0 or credit_balance > MAX_INT - gain:
		return false
	balances[debit_key] = debit_balance - cost
	balances[credit_key] = credit_balance + gain
	return true
