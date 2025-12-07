# Module 01: Flutter for React Developers

**Duration:** 2-3 hours | **Difficulty:** Beginner | **Prerequisites:** React basics

## 🎯 Learning Objectives

After this module, you will:
- Understand how Flutter differs from React conceptually
- Translate React component patterns to Flutter widgets
- Understand the widget tree vs virtual DOM
- Know how rendering and rebuilds work in Flutter
- Write your first Flutter UI with confidence

---

## 📋 Table of Contents

1. [Mental Model Shift](#mental-model-shift)
2. [Components vs Widgets](#components-vs-widgets)
3. [JSX vs Dart UI Code](#jsx-vs-dart-ui-code)
4. [Props vs Constructor Parameters](#props-vs-constructor-parameters)
5. [State Management Basics](#state-management-basics)
6. [Lifecycle Comparison](#lifecycle-comparison)
7. [Styling: CSS vs Flutter](#styling-css-vs-flutter)
8. [Lists and Iteration](#lists-and-iteration)
9. [Conditional Rendering](#conditional-rendering)
10. [Event Handling](#event-handling)
11. [Quick Reference](#quick-reference)
12. [Practice Exercises](#practice-exercises)

---

## Mental Model Shift

### The Big Picture

```
React Rendering Pipeline:
    JSX → Virtual DOM → Reconciliation → Real DOM

Flutter Rendering Pipeline:
    Widget Tree → Element Tree → Render Tree → Canvas/Pixels

Side-by-side comparison:

    React                          Flutter
    ─────                          ───────

    ┌─────┐                       ┌─────────────┐
    │ JSX │                       │ Widget Tree │
    └──┬──┘                       └──────┬──────┘
       │                                 │
       ↓                                 ↓
    ┌────────────┐                ┌──────────────┐
    │ Virtual DOM│                │ Element Tree │
    └─────┬──────┘                └──────┬───────┘
          │                               │
          ↓                               ↓
    ┌──────────────┐              ┌─────────────┐
    │Reconciliation│              │ Render Tree │
    └──────┬───────┘              └──────┬──────┘
           │                              │
           ↓                              ↓
    ┌──────────┐                  ┌──────────────┐
    │ Real DOM │                  │Canvas/Pixels │
    └──────────┘                  └──────────────┘
```

### Key Differences

| Aspect | React | Flutter |
|--------|-------|---------|
| **Language** | JavaScript/TypeScript + JSX | Dart (no separate template language) |
| **UI Declaration** | JSX (HTML-like syntax) | Dart code (everything is code) |
| **Rendering** | Virtual DOM diffing | Widget tree rebuilding |
| **Styling** | CSS, styled-components, Tailwind | Inline style properties, Theme |
| **Components** | Functions or Classes | Stateless or Stateful Widgets |
| **State** | useState, useReducer, Redux | setState, Riverpod, Provider |
| **Effects** | useEffect | Widget lifecycle methods, Riverpod |

### Mental Model Analogy

**React:** "I declare UI with HTML-like syntax, React figures out what changed"
**Flutter:** "I declare UI with Dart classes, Flutter rebuilds efficiently"

Both are declarative, but Flutter has **no separation** between logic and UI markup.

---

## Components vs Widgets

### React Component

```typescript
// React: Functional Component
interface Props {
  name: string;
  age: number;
  onPress: () => void;
}

const UserCard: React.FC<Props> = ({ name, age, onPress }) => {
  return (
    <div className="card" onClick={onPress}>
      <h2>{name}</h2>
      <p>Age: {age}</p>
    </div>
  );
};
```

### Flutter Widget (Equivalent)

```dart
// Flutter: StatelessWidget
class UserCard extends StatelessWidget {
  final String name;
  final int age;
  final VoidCallback onPress;

  const UserCard({
    super.key,
    required this.name,
    required this.age,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 24),
            ),
            Text('Age: $age'),
          ],
        ),
      ),
    );
  }
}
```

### Key Observations

1. **No JSX** - Flutter uses pure Dart code
2. **Props = Constructor Parameters** - Passed via constructor, not as function arguments
3. **build() = return** - The `build` method is like React's return statement
4. **Const constructors** - `const` keyword for performance (immutable widgets)
5. **Widget wrapping** - Widgets are nested like JSX, but using constructors

---

## JSX vs Dart UI Code

### React (JSX)

```typescript
// React: JSX feels like HTML
const Profile = () => {
  return (
    <div className="container">
      <img src={avatarUrl} alt="Avatar" />
      <div className="info">
        <h1>{userName}</h1>
        <p>{userBio}</p>
      </div>
    </div>
  );
};
```

### Flutter (Dart)

```dart
// Flutter: Nested widget constructors
class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Image.network(avatarUrl),
          Column(
            children: [
              Text(
                userName,
                style: TextStyle(fontSize: 24),
              ),
              Text(userBio),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Why No JSX?

Flutter chose to **use Dart code directly** instead of a template language:

**Pros:**
- ✅ Full power of the language (no template limitations)
- ✅ Better tooling (autocomplete, refactoring)
- ✅ Type safety everywhere
- ✅ Easier to learn (one language)

**Cons:**
- ❌ More nesting (can get deep)
- ❌ Less "HTML-like" (steeper learning curve from web)

### Reading Flutter UI Code

**Think of it as:**
```
Widget(
  property: value,
  child: ChildWidget(...)  // Single child
)

Widget(
  property: value,
  children: [              // Multiple children
    ChildWidget1(),
    ChildWidget2(),
  ]
)
```

---

## Props vs Constructor Parameters

### React: Props

```typescript
// React: Props object
interface ButtonProps {
  title: string;
  color?: string;
  disabled?: boolean;
  onPress: () => void;
}

const Button: React.FC<ButtonProps> = ({
  title,
  color = 'blue',
  disabled = false,
  onPress
}) => {
  return (
    <button
      style={{ backgroundColor: color }}
      disabled={disabled}
      onClick={onPress}
    >
      {title}
    </button>
  );
};

// Usage
<Button title="Click Me" onPress={() => console.log('Clicked')} />
```

### Flutter: Constructor Parameters

```dart
// Flutter: Constructor parameters with named arguments
class Button extends StatelessWidget {
  final String title;
  final Color color;
  final bool disabled;
  final VoidCallback onPress;

  const Button({
    super.key,
    required this.title,
    this.color = Colors.blue,
    this.disabled = false,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: disabled ? null : onPress,
      child: Text(title),
    );
  }
}

// Usage
Button(
  title: 'Click Me',
  onPress: () => print('Clicked'),
)
```

### Key Differences

| Feature | React | Flutter |
|---------|-------|---------|
| **Pass data** | Props object | Constructor parameters |
| **Optional** | `?:` in TypeScript | `required` keyword or default value |
| **Defaults** | `= value` in destructuring | `= value` in constructor |
| **Children** | `{children}` prop | `child` or `children` parameter |
| **Immutability** | By convention | Enforced with `final` |

---

## State Management Basics

### React: useState

```typescript
// React: useState hook
const Counter = () => {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  );
};
```

### Flutter: StatefulWidget

```dart
// Flutter: StatefulWidget with setState
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### Understanding StatefulWidget

**Why two classes?**

1. **Widget class** (`Counter`) - Immutable configuration
2. **State class** (`_CounterState`) - Mutable state

Think of it like:
- **Widget** = React component definition
- **State** = The instance with state

```
StatefulWidget Lifecycle:

    ┌────────────────┐
    │ Counter Widget │ (Immutable configuration)
    └────────┬───────┘
             │
             │ createState()
             ↓
    ┌────────────────────┐
    │ _CounterState      │ (Mutable state instance)
    │    Instance         │◄─────┐
    └────────┬───────────┘       │
             │                    │
             │ build()         setState()
             ↓                    │
    ┌────────────────────┐       │
    │     UI Tree         │       │
    │  (Widgets rendered) │       │
    └─────────────────────┘       │
             │                    │
             └────────────────────┘
                   rebuild
```

### Key Points

- `StatelessWidget` = React functional component without state
- `StatefulWidget` = React functional component with useState
- `setState()` = `setCount()` in React - triggers rebuild
- State is **private to the State class**

---

## Lifecycle Comparison

### React Hooks Lifecycle

```typescript
// React: useEffect for side effects
const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);

  // Mount & userId change
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // Mount only
  useEffect(() => {
    console.log('Component mounted');
  }, []);

  // Cleanup
  useEffect(() => {
    return () => console.log('Unmounting');
  }, []);

  return <div>{user?.name}</div>;
};
```

### Flutter StatefulWidget Lifecycle

```dart
// Flutter: Lifecycle methods
class UserProfile extends StatefulWidget {
  final String userId;
  const UserProfile({super.key, required this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  User? user;

  @override
  void initState() {
    super.initState();
    // Mount only - like useEffect with []
    print('Component mounted');
    _fetchUser();
  }

  @override
  void didUpdateWidget(UserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Like useEffect with [userId] dependency
    if (widget.userId != oldWidget.userId) {
      _fetchUser();
    }
  }

  @override
  void dispose() {
    // Cleanup - like useEffect return function
    print('Unmounting');
    super.dispose();
  }

  Future<void> _fetchUser() async {
    final fetchedUser = await fetchUser(widget.userId);
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(user?.name ?? 'Loading...');
  }
}
```

### Lifecycle Methods Mapping

| React Hook | Flutter Method | Purpose |
|------------|----------------|---------|
| `useEffect(() => {}, [])` | `initState()` | Run once on mount |
| `useEffect(() => {}, [dep])` | `didUpdateWidget()` | Run when props change |
| `useEffect(() => { return cleanup })` | `dispose()` | Cleanup on unmount |
| `useMemo()` | `build()` optimization | Memoization (Flutter does this automatically) |
| `useCallback()` | Method reference | Flutter methods are stable by default |

---

## Styling: CSS vs Flutter

### React: CSS/Tailwind

```typescript
// React: External CSS or inline styles
const Card = () => {
  return (
    <div
      style={{
        backgroundColor: 'white',
        padding: '16px',
        borderRadius: '8px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }}
    >
      <h2 style={{ fontSize: '24px', fontWeight: 'bold' }}>
        Title
      </h2>
    </div>
  );
};
```

### Flutter: Inline Widget Properties

```dart
// Flutter: Properties on widgets
class Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Text(
        'Title',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### Common Style Mappings

| CSS Property | Flutter Widget/Property |
|--------------|------------------------|
| `background-color` | `Container(color: ...)` or `decoration: BoxDecoration(color: ...)` |
| `padding` | `Padding(padding: EdgeInsets.all(16))` or `Container(padding: ...)` |
| `margin` | `Container(margin: EdgeInsets.all(16))` |
| `border-radius` | `BoxDecoration(borderRadius: BorderRadius.circular(8))` |
| `box-shadow` | `BoxDecoration(boxShadow: [...])` |
| `display: flex` | `Row()`, `Column()`, or `Flex()` |
| `font-size` | `TextStyle(fontSize: 16)` |
| `font-weight` | `TextStyle(fontWeight: FontWeight.bold)` |
| `color` (text) | `TextStyle(color: Colors.black)` |

### Layout Comparison

**React Flexbox:**
```typescript
<div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

**Flutter:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text('Item 1'),
    Text('Item 2'),
  ],
)
```

| CSS Flex | Flutter |
|----------|---------|
| `flex-direction: row` | `Row()` |
| `flex-direction: column` | `Column()` |
| `justify-content` | `mainAxisAlignment` |
| `align-items` | `crossAxisAlignment` |
| `flex: 1` | `Expanded()` widget |

---

## Lists and Iteration

### React: map()

```typescript
// React: Array.map() to render lists
const UserList = ({ users }) => {
  return (
    <div>
      {users.map(user => (
        <div key={user.id}>
          <h3>{user.name}</h3>
          <p>{user.email}</p>
        </div>
      ))}
    </div>
  );
};
```

### Flutter: map() or ListView

```dart
// Flutter: Method 1 - map() like React
class UserList extends StatelessWidget {
  final List<User> users;
  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: users.map((user) {
        return Container(
          child: Column(
            children: [
              Text(user.name),
              Text(user.email),
            ],
          ),
        );
      }).toList(), // Must convert to List
    );
  }
}

// Flutter: Method 2 - ListView.builder (better for performance)
class UserList extends StatelessWidget {
  final List<User> users;
  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      },
    );
  }
}
```

### Key Differences

| React | Flutter |
|-------|---------|
| `array.map()` | `list.map().toList()` or `ListView.builder` |
| `key` prop for reconciliation | `key` parameter (optional, but recommended) |
| Virtual scrolling (windowing) optional | `ListView.builder` lazy loads by default |

### Which to Use?

- **Short lists (< 20 items):** `map().toList()` is fine
- **Long lists:** Use `ListView.builder()` for performance (lazy rendering)
- **Infinite scroll:** Use `ListView.builder()` with pagination

---

## Conditional Rendering

### React: Ternary & &&

```typescript
// React: Multiple patterns
const Greeting = ({ isLoggedIn, user }) => {
  return (
    <div>
      {isLoggedIn ? (
        <h1>Welcome back, {user.name}!</h1>
      ) : (
        <h1>Please log in</h1>
      )}

      {user.isPremium && <Badge>Premium</Badge>}
    </div>
  );
};
```

### Flutter: Ternary & if statements

```dart
// Flutter: Ternary and conditional expressions
class Greeting extends StatelessWidget {
  final bool isLoggedIn;
  final User? user;

  const Greeting({
    super.key,
    required this.isLoggedIn,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ternary operator
        isLoggedIn
            ? Text('Welcome back, ${user?.name}!')
            : Text('Please log in'),

        // Conditional in list (Dart 2.3+)
        if (user?.isPremium == true)
          Badge(text: 'Premium'),
      ],
    );
  }
}
```

### Flutter Conditional Patterns

```dart
// Pattern 1: Ternary operator
condition ? Widget1() : Widget2()

// Pattern 2: if statement in list
children: [
  if (condition) Widget1(),
  if (otherCondition) Widget2(),
]

// Pattern 3: Helper method
Widget _buildContent() {
  if (condition1) return Widget1();
  if (condition2) return Widget2();
  return Widget3();
}

// Pattern 4: Null-aware with ??
user?.name ?? 'Guest'
```

---

## Event Handling

### React: onClick, onChange, etc.

```typescript
// React: Event handlers
const LoginForm = () => {
  const [email, setEmail] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Submitting:', email);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        onFocus={() => console.log('Focused')}
      />
      <button onClick={handleSubmit}>Submit</button>
    </form>
  );
};
```

### Flutter: Callbacks

```dart
// Flutter: Callback parameters
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String email = '';

  void _handleSubmit() {
    print('Submitting: $email');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              email = value;
            });
          },
          onTap: () => print('Focused'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
```

### Event Handler Mappings

| React Event | Flutter Callback | Widget |
|-------------|------------------|--------|
| `onClick` | `onPressed` or `onTap` | `ElevatedButton`, `GestureDetector` |
| `onChange` | `onChanged` | `TextField`, `Checkbox` |
| `onSubmit` | `onFieldSubmitted` | `TextField` |
| `onFocus` | `onTap` | `TextField`, `GestureDetector` |
| `onMouseEnter` | `onEnter` | `MouseRegion` |
| `onScroll` | `onNotification` | `NotificationListener` |

---

## Quick Reference

### Cheat Sheet

```dart
// StatelessWidget (like React functional component, no state)
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// StatefulWidget (like React component with useState)
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int counter = 0; // State variable

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          counter++; // Update state
        });
      },
      child: Text('Count: $counter'),
    );
  }
}

// Common Layout Widgets
Row(children: [...])           // Horizontal
Column(children: [...])        // Vertical
Stack(children: [...])         // Overlapping
Container(child: ...)          // Box model (padding, margin, etc.)
Padding(child: ...)            // Just padding
Center(child: ...)             // Center align
Expanded(child: ...)           // Flex: 1

// Common UI Widgets
Text('Hello')
Image.network(url)
Icon(Icons.home)
TextField(onChanged: ...)
ElevatedButton(onPressed: ..., child: ...)
```

### React → Flutter Quick Map

| React Concept | Flutter Equivalent |
|---------------|-------------------|
| `<div>` | `Container()` |
| `<span>`, `<p>` | `Text()` |
| `<img>` | `Image()` |
| `<button>` | `ElevatedButton()` or `TextButton()` |
| `<input>` | `TextField()` |
| `className` | Widget properties |
| `style` | Widget properties or `TextStyle()` |
| `onClick` | `onPressed` or `onTap` |
| `{children}` | `child` or `children` parameter |
| Fragment `<>` | `Column()` or `Row()` (must have layout) |

---

## Practice Exercises

### Exercise 1: Hello World (15 minutes)

**Goal:** Create your first Flutter widget

**React Version:**
```typescript
const HelloWorld = () => {
  return <h1>Hello, Flutter!</h1>;
};
```

**Your Task:** Convert this to a Flutter `StatelessWidget`

<details>
<summary>Solution</summary>

```dart
class HelloWorld extends StatelessWidget {
  const HelloWorld({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, Flutter!',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
```
</details>

---

### Exercise 2: Props/Parameters (20 minutes)

**Goal:** Pass data between widgets

**React Version:**
```typescript
interface UserCardProps {
  name: string;
  email: string;
  avatarUrl: string;
}

const UserCard: React.FC<UserCardProps> = ({ name, email, avatarUrl }) => {
  return (
    <div className="card">
      <img src={avatarUrl} alt={name} />
      <h2>{name}</h2>
      <p>{email}</p>
    </div>
  );
};
```

**Your Task:** Create a Flutter equivalent with constructor parameters

<details>
<summary>Solution</summary>

```dart
class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 40,
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(email),
        ],
      ),
    );
  }
}
```
</details>

---

### Exercise 3: State Management (30 minutes)

**Goal:** Create a counter with state

**React Version:**
```typescript
const Counter = () => {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  );
};
```

**Your Task:** Convert to a Flutter `StatefulWidget` with three buttons

<details>
<summary>Solution</summary>

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Count: $count',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  count++;
                });
              },
              child: Text('+'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  count--;
                });
              },
              child: Text('-'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  count = 0;
                });
              },
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
```
</details>

---

### Exercise 4: List Rendering (30 minutes)

**Goal:** Render a dynamic list of items

**React Version:**
```typescript
const TodoList = () => {
  const todos = ['Buy milk', 'Walk dog', 'Write code'];

  return (
    <ul>
      {todos.map((todo, index) => (
        <li key={index}>{todo}</li>
      ))}
    </ul>
  );
};
```

**Your Task:** Create a Flutter widget that displays a list using `ListView.builder`

<details>
<summary>Solution</summary>

```dart
class TodoList extends StatelessWidget {
  final List<String> todos = ['Buy milk', 'Walk dog', 'Write code'];

  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.check_circle_outline),
          title: Text(todos[index]),
        );
      },
    );
  }
}
```
</details>

---

### Exercise 5: Conditional Rendering (20 minutes)

**Goal:** Show/hide UI based on conditions

**React Version:**
```typescript
const Greeting = ({ isLoggedIn }) => {
  return (
    <div>
      {isLoggedIn ? (
        <h1>Welcome back!</h1>
      ) : (
        <button>Log In</button>
      )}
    </div>
  );
};
```

**Your Task:** Create a Flutter widget with conditional UI

<details>
<summary>Solution</summary>

```dart
class Greeting extends StatelessWidget {
  final bool isLoggedIn;

  const Greeting({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoggedIn
          ? Text(
              'Welcome back!',
              style: TextStyle(fontSize: 24),
            )
          : ElevatedButton(
              onPressed: () {
                print('Log in pressed');
              },
              child: Text('Log In'),
            ),
    );
  }
}
```
</details>

---

## Next Steps

Congratulations! You now understand the fundamental differences between React and Flutter.

**Next Module:** [02: Dart Fundamentals →](02-dart-fundamentals.md)

In the next module, you'll dive deep into the Dart language and learn syntax, types, async/await, and more from a TypeScript perspective.

---

## Summary Checklist

- [ ] I understand widgets are like React components
- [ ] I can read Flutter UI code (nested constructors)
- [ ] I know the difference between StatelessWidget and StatefulWidget
- [ ] I understand how to pass data (props → constructor parameters)
- [ ] I can use setState() to update UI
- [ ] I know how to render lists with map() or ListView.builder
- [ ] I can conditionally render widgets
- [ ] I can handle button clicks and input changes

**Ready to continue?** Move on to [Module 02: Dart Fundamentals](02-dart-fundamentals.md)
