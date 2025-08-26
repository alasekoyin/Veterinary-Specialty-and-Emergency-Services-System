;; Emergency Cases Contract
;; Manages emergency veterinary cases and triage

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-INVALID-TRIAGE (err u422))
(define-constant ERR-INVALID-STATUS (err u423))

;; Data Variables
(define-data-var next-case-id uint u1)

;; Data Maps
(define-map emergency-cases
  { case-id: uint }
  {
    patient-id: uint,
    reporting-vet-id: uint,
    receiving-vet-id: uint,
    triage-level: uint,
    chief-complaint: (string-ascii 500),
    vital-signs: (string-ascii 300),
    initial-assessment: (string-ascii 500),
    treatment-plan: (string-ascii 500),
    status: (string-ascii 20),
    arrival-time: uint,
    triage-time: uint,
    treatment-start: uint,
    discharge-time: uint,
    follow-up-required: bool,
    follow-up-instructions: (string-ascii 500)
  }
)

(define-map case-treatments
  { case-id: uint, treatment-id: uint }
  {
    treatment-type: (string-ascii 100),
    medication: (string-ascii 100),
    dosage: (string-ascii 50),
    administration-time: uint,
    administered-by: uint,
    response: (string-ascii 300),
    notes: (string-ascii 500)
  }
)

(define-map case-vitals
  { case-id: uint, reading-time: uint }
  {
    temperature: uint,
    heart-rate: uint,
    respiratory-rate: uint,
    blood-pressure-systolic: uint,
    blood-pressure-diastolic: uint,
    oxygen-saturation: uint,
    pain-score: uint,
    consciousness-level: (string-ascii 20),
    recorded-by: uint
  }
)

(define-map case-handoffs
  { case-id: uint, handoff-id: uint }
  {
    from-vet-id: uint,
    to-vet-id: uint,
    handoff-time: uint,
    reason: (string-ascii 200),
    patient-status: (string-ascii 300),
    pending-tasks: (string-ascii 500),
    special-instructions: (string-ascii 500)
  }
)

;; Public Functions

;; Create emergency case
(define-public (create-emergency-case
  (patient-id uint)
  (reporting-vet-id uint)
  (triage-level uint)
  (chief-complaint (string-ascii 500))
  (vital-signs (string-ascii 300))
  (initial-assessment (string-ascii 500))
)
  (let ((case-id (var-get next-case-id)))
    (asserts! (> patient-id u0) ERR-INVALID-INPUT)
    (asserts! (> reporting-vet-id u0) ERR-INVALID-INPUT)
    (asserts! (and (>= triage-level u1) (<= triage-level u5)) ERR-INVALID-TRIAGE)
    (asserts! (> (len chief-complaint) u0) ERR-INVALID-INPUT)

    (map-set emergency-cases
      { case-id: case-id }
      {
        patient-id: patient-id,
        reporting-vet-id: reporting-vet-id,
        receiving-vet-id: reporting-vet-id,
        triage-level: triage-level,
        chief-complaint: chief-complaint,
        vital-signs: vital-signs,
        initial-assessment: initial-assessment,
        treatment-plan: "",
        status: "active",
        arrival-time: block-height,
        triage-time: block-height,
        treatment-start: u0,
        discharge-time: u0,
        follow-up-required: false,
        follow-up-instructions: ""
      }
    )

    (var-set next-case-id (+ case-id u1))
    (ok case-id)
  )
)

;; Update triage level
(define-public (update-triage
  (case-id uint)
  (new-triage-level uint)
  (vet-id uint)
  (assessment-notes (string-ascii 500))
)
  (let ((case-data (unwrap! (map-get? emergency-cases { case-id: case-id }) ERR-NOT-FOUND)))
    (asserts! (or
      (is-eq (get reporting-vet-id case-data) vet-id)
      (is-eq (get receiving-vet-id case-data) vet-id)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= new-triage-level u1) (<= new-triage-level u5)) ERR-INVALID-TRIAGE)
    (asserts! (not (is-eq (get status case-data) "discharged")) ERR-INVALID-STATUS)

    (map-set emergency-cases
      { case-id: case-id }
      (merge case-data {
        triage-level: new-triage-level,
        initial-assessment: assessment-notes,
        triage-time: block-height
      })
    )
    (ok true)
  )
)

;; Start treatment
(define-public (start-treatment
  (case-id uint)
  (treating-vet-id uint)
  (treatment-plan (string-ascii 500))
)
  (let ((case-data (unwrap! (map-get? emergency-cases { case-id: case-id }) ERR-NOT-FOUND)))
    (asserts! (> treating-vet-id u0) ERR-INVALID-INPUT)
    (asserts! (> (len treatment-plan) u0) ERR-INVALID-INPUT)
    (asserts! (is-eq (get status case-data) "active") ERR-INVALID-STATUS)

    (map-set emergency-cases
      { case-id: case-id }
      (merge case-data {
        receiving-vet-id: treating-vet-id,
        treatment-plan: treatment-plan,
        status: "in-treatment",
        treatment-start: block-height
      })
    )
    (ok true)
  )
)

;; Add treatment record
(define-public (add-treatment
  (case-id uint)
  (treatment-id uint)
  (treatment-type (string-ascii 100))
  (medication (string-ascii 100))
  (dosage (string-ascii 50))
  (administered-by uint)
  (response (string-ascii 300))
  (notes (string-ascii 500))
)
  (let ((case-data (unwrap! (map-get? emergency-cases { case-id: case-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get receiving-vet-id case-data) administered-by) ERR-NOT-AUTHORIZED)
    (asserts! (> (len treatment-type) u0) ERR-INVALID-INPUT)
    (asserts! (not (is-eq (get status case-data) "discharged")) ERR-INVALID-STATUS)

    (map-set case-treatments
      { case-id: case-id, treatment-id: treatment-id }
      {
        treatment-type: treatment-type,
        medication: medication,
        dosage: dosage,
        administration-time: block-height,
        administered-by: administered-by,
        response: response,
        notes: notes
      }
    )
    (ok true)
  )
)

;; Record vital signs
(define-public (record-vitals
  (case-id uint)
  (temperature uint)
  (heart-rate uint)
  (respiratory-rate uint)
  (blood-pressure-systolic uint)
  (blood-pressure-diastolic uint)
  (oxygen-saturation uint)
  (pain-score uint)
  (consciousness-level (string-ascii 20))
  (recorded-by uint)
)
  (let ((case-data (unwrap! (map-get? emergency-cases { case-id: case-id }) ERR-NOT-FOUND)))
    (asserts! (or
      (is-eq (get reporting-vet-id case-data) recorded-by)
      (is-eq (get receiving-vet-id case-data) recorded-by)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= pain-score u0) (<= pain-score u10)) ERR-INVALID-INPUT)
    (asserts! (not (is-eq (get status case-data) "discharged")) ERR-INVALID-STATUS)

    (map-set case-vitals
      { case-id: case-id, reading-time: block-height }
      {
        temperature: temperature,
        heart-rate: heart-rate,
        respiratory-rate: respiratory-rate,
        blood-pressure-systolic: blood-pressure-systolic,
        blood-pressure-diastolic: blood-pressure-diastolic,
        oxygen-saturation: oxygen-saturation,
        pain-score: pain-score,
        consciousness-level: consciousness-level,
        recorded-by: recorded-by
      }
    )
    (ok true)
  )
)

;; Discharge patient
(define-public (discharge-patient
  (case-id uint)
  (discharging-vet-id uint)
  (follow-up-required bool)
  (follow-up-instructions (string-ascii 500))
)
  (let ((case-data (unwrap! (map-get? emergency-cases { case-id: case-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get receiving-vet-id case-data) discharging-vet-id) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq (get status case-data) "discharged")) ERR-INVALID-STATUS)

    (map-set emergency-cases
      { case-id: case-id }
      (merge case-data {
        status: "discharged",
        discharge-time: block-height,
        follow-up-required: follow-up-required,
        follow-up-instructions: follow-up-instructions
      })
    )
    (ok true)
  )
)

;; Hand off case to another vet
(define-public (handoff-case
  (case-id uint)
  (handoff-id uint)
  (from-vet-id uint)
  (to-vet-id uint)
  (reason (string-ascii 200))
  (patient-status (string-ascii 300))
  (pending-tasks (string-ascii 500))
  (special-instructions (string-ascii 500))
)
  (let ((case-data (unwrap! (map-get? emergency-cases { case-id: case-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get receiving-vet-id case-data) from-vet-id) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq from-vet-id to-vet-id)) ERR-INVALID-INPUT)
    (asserts! (> (len reason) u0) ERR-INVALID-INPUT)
    (asserts! (not (is-eq (get status case-data) "discharged")) ERR-INVALID-STATUS)

    ;; Record handoff
    (map-set case-handoffs
      { case-id: case-id, handoff-id: handoff-id }
      {
        from-vet-id: from-vet-id,
        to-vet-id: to-vet-id,
        handoff-time: block-height,
        reason: reason,
        patient-status: patient-status,
        pending-tasks: pending-tasks,
        special-instructions: special-instructions
      }
    )

    ;; Update case with new receiving vet
    (map-set emergency-cases
      { case-id: case-id }
      (merge case-data { receiving-vet-id: to-vet-id })
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get emergency case
(define-read-only (get-emergency-case (case-id uint))
  (map-get? emergency-cases { case-id: case-id })
)

;; Get case treatment
(define-read-only (get-case-treatment (case-id uint) (treatment-id uint))
  (map-get? case-treatments { case-id: case-id, treatment-id: treatment-id })
)

;; Get case vitals
(define-read-only (get-case-vitals (case-id uint) (reading-time uint))
  (map-get? case-vitals { case-id: case-id, reading-time: reading-time })
)

;; Get case handoff
(define-read-only (get-case-handoff (case-id uint) (handoff-id uint))
  (map-get? case-handoffs { case-id: case-id, handoff-id: handoff-id })
)

;; Check if case is active
(define-read-only (is-case-active (case-id uint))
  (match (map-get? emergency-cases { case-id: case-id })
    case-data (not (is-eq (get status case-data) "discharged"))
    false
  )
)

;; Get next case ID
(define-read-only (get-next-case-id)
  (var-get next-case-id)
)
