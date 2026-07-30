# Security Review

## Backend Inventory
- **Framework**: Node.js / Express
- **Language**: JavaScript
- **Api_Architecture**: REST API with Express router mounted at /api
- **Authentication**: JWT + Firebase Admin fallback + custom authorization middleware
- **Authorization**: Role-based access through req.user.role and route-level middleware
- **Database**: MongoDB via Mongoose
- **Orm**: Mongoose ODM
- **Api_Documentation**: No formal OpenAPI/Swagger definition detected
- **Middleware**: cors, express.json, express.urlencoded, custom auth middleware
- **File_Upload**: Base64/JSON payload uploads via express.json; no dedicated file upload handler detected
- **Session_Handling**: JWT tokens; no server-side session store detected
- **Integrations**: Firebase Admin SDK, Google Generative AI, MongoDB

## Findings
### 1. High - Authentication Bypass / Demo Token Weakness
- **File**: petorb_server/src/middleware/authMiddleware.js
- **Endpoint**: /api/*
- **Description**: The middleware accepts a dev_uid_ token prefix and bypasses validation by looking up a user in MongoDB. This creates a trivial authentication bypass for anyone who knows the token pattern.
- **Exploitation Scenario**: An attacker can supply a token beginning with dev_uid_ and access protected routes if the corresponding user exists.
- **Impact**: Unauthorized access to profile, pet, job, QR, and AI resources.
- **Recommended Fix**: Remove the development bypass and require valid signed JWTs or Firebase ID tokens only.

### 2. High - Hardcoded JWT Secret
- **File**: petorb_server/src/controllers/authController.js
- **Endpoint**: /api/auth/login
- **Description**: The application falls back to a hardcoded JWT secret when JWT_SECRET is not set.
- **Exploitation Scenario**: An attacker can forge tokens if the fallback secret is known and the environment variable is absent.
- **Impact**: Token forgery and privilege escalation.
- **Recommended Fix**: Require a strong secret from the environment and fail closed if absent.

### 3. Medium - Missing Security Headers / Weak CORS
- **File**: petorb_server/src/server.js
- **Endpoint**: /api/*
- **Description**: The server enables CORS globally without a restricted origin policy and does not set common security headers such as X-Content-Type-Options or Content-Security-Policy.
- **Exploitation Scenario**: A malicious site can read responses from the API if the browser context is allowed and exploit cross-origin behavior.
- **Impact**: Cross-origin data exposure and browser-based attacks.
- **Recommended Fix**: Restrict CORS to trusted origins and add security headers via helmet.

### 4. Medium - Public Lost Pet Recovery Endpoint
- **File**: petorb_server/src/routes/api.js
- **Endpoint**: /api/qr/lost-pet/:petId
- **Description**: A QR route is exposed without authentication and returns data based on a pet identifier.
- **Exploitation Scenario**: An unauthenticated user can enumerate pet-associated information by probing the public route.
- **Impact**: Information disclosure and privacy exposure.
- **Recommended Fix**: Require authentication or add an access control gate and rate limiting.

### 5. Low - Verbose Error Exposure
- **File**: petorb_server/src/server.js
- **Endpoint**: /api/*
- **Description**: The error middleware returns detailed error information in development mode.
- **Exploitation Scenario**: Attackers can use error responses to infer implementation details or stack traces.
- **Impact**: Information disclosure.
- **Recommended Fix**: Disable detailed error messages in non-production environments.
