# Veterinary Specialty and Emergency Services System

A comprehensive blockchain-based system for managing veterinary specialty and emergency services using Clarity smart contracts. This system enables seamless coordination between general practice and specialty veterinarians while maintaining complete data integrity and transparency.

## System Overview

The system consists of five self-contained smart contracts that work independently to manage:

- **Veterinarian Registration and Credentials** - Manages vet profiles, specialties, and licensing
- **Patient Records Management** - Secure patient data storage and access control
- **Referral Coordination System** - Streamlines referrals between general and specialty practices
- **Emergency Case Management** - Handles urgent cases with triage and treatment tracking
- **Transparent Pricing System** - Provides clear pricing for procedures and treatments

## Key Features

### 🏥 Referral Coordination
- Seamless handoffs between general practice and specialty veterinarians
- Automated referral tracking and status updates
- Secure transfer of patient information and medical history

### 🚨 Emergency Case Management
- Real-time emergency case registration and triage
- Treatment continuity tracking across multiple providers
- Critical case escalation and notification system

### 💰 Transparent Pricing
- Clear, upfront pricing for specialized procedures
- Treatment cost estimation and approval workflow
- Insurance and payment coordination

### 🔒 Secure Data Sharing
- Encrypted diagnostic image and test result sharing
- Granular access control for patient information
- HIPAA-compliant data handling and storage

### 🕐 After-Hours Coordination
- 24/7 emergency case coordination
- Follow-up scheduling and care continuity
- Cross-practice communication and handoffs

## Contract Architecture

Each contract is completely self-contained with no cross-contract dependencies:

1. **vet-registry.clar** - Independent veterinarian management
2. **patient-records.clar** - Standalone patient data system
3. **referral-system.clar** - Self-contained referral workflow
4. **emergency-cases.clar** - Independent emergency management
5. **pricing-transparency.clar** - Standalone pricing system

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

4. Deploy contracts:
   \`\`\`bash
   clarinet deploy
   \`\`\`

## Testing

The system includes comprehensive test coverage using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm test vet-registry
npm test patient-records
npm test referral-system
npm test emergency-cases
npm test pricing-transparency
\`\`\`

## Contract Functions

### Vet Registry
- `register-vet` - Register new veterinarian
- `update-vet-status` - Activate/deactivate vet
- `add-specialty` - Add specialty certification
- `get-vet-info` - Retrieve vet information

### Patient Records
- `create-patient` - Register new patient
- `update-patient` - Update patient information
- `add-medical-record` - Add medical history entry
- `grant-access` - Provide access to other vets

### Referral System
- `create-referral` - Initiate referral process
- `accept-referral` - Accept incoming referral
- `update-referral-status` - Track referral progress
- `complete-referral` - Close referral case

### Emergency Cases
- `create-emergency-case` - Register emergency
- `update-triage` - Set triage priority
- `assign-treatment` - Assign treating veterinarian
- `update-case-status` - Track case progress

### Pricing Transparency
- `set-procedure-price` - Define procedure costs
- `create-estimate` - Generate treatment estimate
- `approve-estimate` - Client approval workflow
- `process-payment` - Handle payment processing

## Security Features

- Input validation on all functions
- Access control for sensitive operations
- Data integrity checks
- Error handling and recovery

## License

MIT License - see LICENSE file for details
