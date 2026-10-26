# Informe de corrección — Taller 2: El intérprete de Cauca
> **Plantilla de entrega.** Copie este archivo a
> `docs/informe-correccion.md` dentro del repositorio del grupo y
> reemplace los marcadores `{{...}}` con su contenido.
> **No elimine las secciones obligatorias.** No se aceptan PDF, DOCX
> ni imágenes insertadas: todo el documento debe ser Markdown, las
> fórmulas en LaTeX (`$...$` / `$$...$$`) y los diagramas en Mermaid.

**Curso:** Fundamentos de Interpretación y Compilación de Lenguajes
de Programación — Universidad del Valle, Sede Tuluá.


**Integrantes del grupo:**

| Nombre | Código | Correo institucional |
|--------|--------|----------------------|
| Adriana Milena Noscue Dagua | 2477336 | adriana.noscue@correounivalle.edu.co |
| Sebastian Cucalon Astorquiza | 2477344 | sebastian.cucalon@correounivalle.edu.co |
| Santiago Torres Rojas | 2380301 | santiago.torres.rojas@correounivalle.edu.co |
| Nicolle Camila Hoyos Puin | 2380608 | nicolle.hoyos@correounivalle.edu.co |	

---

## 1. Marco formal

### 1.1 Corrección de programas recursivos

Sea $f : A \to B$ una función y $A$ un conjunto definido
recursivamente. Sea $P_f$ un programa recursivo en Racket que
pretende calcular $f$. Decimos que $P_f$ es correcto con respecto a
su especificación si se cumple:

$$
\forall a \in A \,:\, P_f(a) = f(a)
$$

La estrategia de demostración es la **inducción estructural**
sobre $A$:

- **Caso base:** para cada valor básico $a_0 \in A$ se verifica
  $P_f(a_0) = f(a_0)$.
- **Caso inductivo:** asumiendo la **hipótesis de inducción**
  $P_f(a') = f(a')$ para las subestructuras $a'$ que forman $a$, se
  demuestra $P_f(a) = f(a)$.

### 1.2 Corrección de programas iterativos

Para un programa iterativo se formalizan:

- Un estado $s$ con componentes relevantes.
- Un estado inicial $s_0$.
- Un estado final reconocido por un predicado $\text{es-final?}(s)$.
- Una **invariante** $\text{Inv}(s)$ que se mantiene entre pasos.
- Una transformación $\text{transformar}(s)$.

La corrección se argumenta demostrando:

1. $\text{Inv}(s_0)$ se cumple al inicio.
2. $\text{Inv}(s) \,\land\, \lnot\text{es-final?}(s)\Rightarrow
   \text{Inv}(\text{transformar}(s))$.
3. $\text{Inv}(s) \,\land\, \text{es-final?}(s)\Rightarrow
   \text{respuesta}(s) = f(\text{entrada})$.
4. El proceso termina (argumentar una función de cota estrictamente
   decreciente sobre $\mathbb{N}$).

---

## 2. Funciones analizadas

> Complete **una subsección por cada función pedida en el enunciado**.
> Copie la plantilla de subsección tantas veces como sea necesario.

### 2.1 Corrección de `apply-procedure`

**Especificación.**

- **Tipo:** `apply-procedure : procval x lista-de-valores -> valor`
- **Pre-condición:** $\text{Pre}(proc, args) \equiv \text{procval?}(proc) \land \text{list?}(args)$.
- **Post-condición:** $\text{Post}(proc, args, r) \equiv r = \text{evaluar-expresion}(body, \text{ambiente-extendido}(ids, args, env_{def}))$, únicamente si $\text{length}(ids) = \text{length}(args)$, donde $env_{def}$ es el ambiente capturado al definir la clausura. Si $proc$ no es un `procval` o las longitudes no coinciden, levanta un `eopl:error` explícito.

**Código.**

```racket
; apply-procedure : procval x lista de valores -> valor
; Propósito: Verifica el operador y la cantidad de argumentos, y evalúa el
; cuerpo en el ambiente de la clausura extendido con los parámetros.
(define apply-procedure
  (lambda (proc args)
    (if (procval? proc)
        (cases procval proc
          (cerradura (ids body env)
            (if (= (length ids) (length args))
                (evaluar-expresion
                 body
                 (ambiente-extendido ids args env))
                (eopl:error 'apply-procedure
                            "Cantidad incorrecta de argumentos"))))
        (eopl:error 'apply-procedure
                    "El operador no es un procedimiento valido"))))
```

**Estrategia de demostración:** Análisis de casos sobre la estructura del valor $proc$ y contraste de cadenas de ambientes sobre el ejemplo de la Parte 3 del enunciado.

**Demostración.**

1. **Evaluación en el ambiente de la clausura vs. ambiente de la llamada:**
   En el ejemplo de contraste del enunciado:
   ```scheme
   let factor = 10 in
     let escalar = proc (v) *(v, factor) end in
       let factor = 1000 in
         apply escalar (5)
       end
     end
   end
   ```

Ámbito Léxico (Correcto = 50): Al evaluar proc (v) *(v, factor) end en el ambiente $\rho_1 = [factor = 10]\,\rho_0$, se crea $v_{escalar} = \text{cerradura}([v], *(v, factor), \rho_1)$. Cuando se invoca apply escalar (5) en el ambiente $\rho_2 = [factor = 1000]\,\rho_1$, apply-procedure extiende únicamente $env_{def} = \rho_1$, obteniendo $\rho_{eval} = [v = 5]\,\rho_1$. La búsqueda de factor en $\rho_{eval}$ retorna $10$, por lo que $*(5, 10) = 50$.

Cadena de ambientes correcta (resultado 50):
graph LR
    E_EVAL["ρ_eval: v=5"] -->|extiende| E1["ρ_1: factor=10"]
    E1 -->|extiende| E0["ρ_0"]

Ámbito Dinámico (Incorrecto = 5000): Si se evaluara en el ambiente de la llamada $\rho_2$, tendríamos $\rho_{dinamico} = [v = 5]\,\rho_2$. La búsqueda de factor retornaría $1000$, dando $*(5, 1000) = 5000$[cite: 9]. 

Cadena de ambientes incorrecta (resultado 5000):
graph LR
    E_DIN["ρ_dinamico: v=5"] -->|extiende| E2["ρ_2: factor=1000"]
    E2 -->|extiende| E1["ρ_1: factor=10"]
    E1 -->|extiende| E0["ρ_0"]

*Manejo de errores explícitos:*
- Si (procval? proc) es falso, (if (procval? proc) ...) toma la rama else y ejecuta (eopl:error 'apply-procedure "El operador no es un procedimiento valido").
- Si (= (length ids) (length args)) es falso, el if interno ejecuta (eopl:error 'apply-procedure "Cantidad incorrecta de argumentos").

*Terminación.*
La función apply-procedure no es recursiva. Realiza un número finito de operaciones secuenciales sobre estructuras de datos finitas:
- Verificación de tipos mediante procval? en $\mathcal{O}(1)$.
- Comparación de longitudes de dos listas finitas (ids y args) mediante length.
- Construcción del ambiente extendido en $\mathcal{O}(1)$.
- Una única llamada delegada a evaluar-expresion para el cuerpo body.

Dado que no contiene bucles ni autollamadas recursivas directas, apply-procedure termina de forma inmediata en tiempo finito en todos los casos.

*Conclusión:* apply-procedure cumple estrictamente con la especificación y preserva el alcan

---

### 2.2 Corrección de la ligadura recursiva`letrec`

**Especificación.**

- **Tipo:** `apply-env : ambiente x symbol -> valor`
- **Invariante de `letrec`:** Para todo procedimiento $f_k$ declarado dentro de una expresión `letrec` con nombres $\{f_1, \dots, f_n\}$, el ambiente en el que se evalúa el cuerpo de $f_k$ al ser invocado contiene las ligaduras de **todos** los procedimientos $\{f_1, \dots, f_n\}$ apuntando a sus respectivas clausuras.
- **Pre-condición:** $\text{Pre}(env, id) \equiv \text{ambiente?}(env) \land \text{symbol?}(id)$.
- **Post-condición:** Si $id$ se encuentra en la variante `ambiente-recursivo`, retorna una `cerradura` cuyo campo de ambiente es el **propio `ambiente-recursivo`**, garantizando que el procedimiento pueda resolver invocaciones recursivas directas o mutuas.

**Código.**

```racket
;; fragmento en apply-env (src/ambiente.rkt)
(ambiente-recursivo (proc-names idss bodies ambiente-anterior)
  (let buscar ((nombres-restantes proc-names)
               (parametros-restantes idss)
               (cuerpos-restantes bodies))
    (cond
      ((null? nombres-restantes)
       (apply-env ambiente-anterior id))
      ((eqv? id (car nombres-restantes))
       (cerradura (car parametros-restantes)
                  (car cuerpos-restantes)
                  env))
      (else
       (buscar (cdr nombres-restantes)
               (cdr parametros-restantes)
               (cdr cuerpos-restantes))))))
```

**Demostración.** 

Construcción de la clausura en apply-env:
Cuando se busca un identificador $id$ dentro de un ambiente-recursivo (donde env es el ambiente-recursivo completo), si $id = f_k$, se retorna (cerradura (car idss_k) (car bodies_k) env). Puesto que el tercer argumento entregado a cerradura es env (el propio ambiente-recursivo), la clausura guarda una referencia cíclica/recursiva al ambiente que contiene todas las funciones declaradas.

Por qué let no satisface la recursión:
En let f = proc (x) ... apply f(...) end in body end, la expresión proc se evalúa en el ambiente exterior $\rho_0$ antes de ligar $f$. Por lo tanto, la clausura de $f$ captura $\rho_0$. Cuando el cuerpo de $f$ intenta evaluarse y busca $f$ en su ambiente de clausura $\rho_0$, $f$ no existe en $\rho_0$, produciendo un error explícito: Variable no definida: f.

Terminación del ejemplo potencia:
Consideremos el procedimiento recursivo potencia(base, exp).
Medida de cota: $\mu(base, exp) = exp \in \mathbb{N}$.
Caso Base: Si $exp = 0$, no hay llamada recursiva; retorna 1 inmediatamente.
Paso Inductivo: Si $exp > 0$, la llamada recursiva pasa $sub1(exp) = exp - 1$. Como $exp - 1 < exp$, la medida decrece estrictamente en cada paso sobre $\mathbb{N}$. Por el principio de buen orden, alcanzará $exp = 0$ en exactamente $exp$ pasos y terminará.

---

### 2.3 Corrección de `case-exp`

Tipo: case-exp : expresion x lista(numero) x lista(expresion) x expresion -> valor
Pre-condición: $\text{Pre}(exp, valores, acciones, default) \equiv \text{evaluar-expresion}(exp, env) \in \mathbb{R}$.
Post-condición: Evalúa $exp$ una sola vez obteniendo $v$. Si $v = valores_i$ para el menor índice $i$, la salida es $\text{evaluar-expresion}(acciones_i, env)$. Si $\forall i, v \neq valores_i$, retorna $\text{evaluar-expresion}(default, env)$. Si $v \notin \mathbb{R}$, levanta eopl:error.

**Código.**

```racket
;; Fragmento de case-exp en evaluar-expresion (src/interprete.rkt)
(case-exp (exp-control valores acciones default)
  (let ((control-value (evaluar-expresion exp-control env)))
    (if (number? control-value)
        (letrec ((recorrer
                  (lambda (vals acts)
                    (cond
                      ((null? vals) (evaluar-expresion default env))
                      ((= control-value (car vals))
                       (evaluar-expresion (car acts) env))
                      (else (recorrer (cdr vals) (cdr acts)))))))
          (recorrer valores acciones))
        (eopl:error 'evaluar-expresion
                    "El valor de control del case debe ser numerico"))))
```


**Demostracion**

Evaluación única de la expresión de control:
En el código de evaluar-expresion, la expresión exp-control se evalúa mediante (let ((control-value (evaluar-expresion exp-control env))) ...). Puesto que esta asignación se realiza afuera de la función recursiva local recorrer, por la semántica de let, evaluar-expresion se ejecuta exactamente una sola vez independientemente de la cantidad de ramas $n$ que contenga el case. El valor numérico resultante se almacena en control-value y se reutiliza para todas las comparaciones de la lista de ramas.   
Demostración por inducción estructural sobre la lista de ramas ($vals$):
Sea $vals$ la lista de literales numéricos y $acts$ la lista de expresiones asociadas a cada rama.   
Caso Base ($vals = ()$ y $acts = ()$): La condición (null? vals) se evalúa verdadera. recorrer retorna (evaluar-expresion default env). Es correcto pues no existía ninguna coincidencia previa en la lista de ramas.   
Caso Inductivo ($vals = \text{cons}(v_0, \text{rest\_vals})$ y $acts = \text{cons}(a_0, \text{rest\_acts})$):Subcaso $control-value = v_0$: La condición (= control-value (car vals)) se cumple. recorrer evalúa y retorna (evaluar-expresion (car acts) env) inmediatamente. Esto demuestra que siempre se selecciona la primera coincidencia.   
Subcaso $control-value \neq v_0$: La condición de igualdad falla y se ejecuta la rama else, invocando (recorrer (cdr vals) (cdr acts)). Por hipótesis de inducción, la llamada recursiva sobre la subestructura de tamaño menor $(\text{rest\_vals}, \text{rest\_acts})$ evaluará la acción de la primera coincidencia que encuentre en la cola o caerá en la rama default en caso de no hallar ninguna[cite: 10, 22].   
Manejo de Errores (Valor no numérico): Si (number? control-value) se evalúa como falso, el condicional principal ejecuta (eopl:error 'evaluar-expresion "El valor de control del case debe ser numerico") sin invocar recorrer, demostrando que el programa levanta error en todos y únicamente en estos casos[cite: 10, 22].

**Termicacion**

Definimos como medida de cota $L(vals) = \text{length}(vals) \in \mathbb{N}$. En cada paso no coincidente de recorrer, la llamada recursiva recibe (cdr vals), cuyo tamaño es $L - 1$. Dado que la lista inicial de ramas generada por el parser SLLGEN es finita ($L < \infty$), la medida decrece estrictamente $L, L-1, L-2, \dots$ hasta encontrar una coincidencia o llegar al caso base $L = 0$. Por el principio de buen orden sobre $\mathbb{N}$, el recorrido sobre las ramas siempre termina en tiempo finito.

**conclusion**

case-exp es correcta respecto a su especificación formal, evalúa el control una sola vez, resuelve correctamente la selección por valor y garantiza la terminación del procedimiento[cite: 10, 22].


---

## 3. Propiedades adicionales (si aplica)

Incluya en esta sección cualquier propiedad adicional que el
enunciado exija demostrar, por ejemplo:

- **Shadowing de ambientes** (`apply-env`): la ligadura más reciente
  tiene prioridad sobre las anteriores.
- **Secuencialidad de `let*`**: cada ligadura se evalúa en un
  ambiente que incluye las anteriores.
- **Equivalencia semántica** entre dos implementaciones (por ejemplo,
  representación basada en listas vs. basada en procedimientos de un
  mismo TAD).
- **Invariante del almacén**: si $\sigma' = \text{setref!}(\sigma, \ell, v)$,
  entonces $\sigma'(\ell) = v$ y $\sigma'(\ell') = \sigma(\ell')$ para todo
  $\ell' \neq \ell$. La operación que reserva una celda es la única que
  cambia la longitud del almacén.
- **Invariante de la transacción**: sea $\sigma_0$ el almacén al entrar a
  un bloque `atomic` y $\sigma$ el almacén en el momento de abortar. Si
  el registro de la transacción guarda, para cada celda $\ell$ escrita
  dentro del bloque, el valor $\sigma_0(\ell)$ que tenía al entrar, y la
  longitud $|\sigma_0|$, entonces revertir devuelve exactamente
  $\sigma_0$: las celdas registradas recuperan su valor, las que no se
  escribieron nunca cambiaron, y las creadas adentro (posiciones
  $\geq |\sigma_0|$) desaparecen. Demostrar por inducción sobre el
  número de escrituras del bloque, y tratar aparte el caso de una
  transacción hija que confirmó antes de que la padre abortara.
- **Paso por referencia**: el parámetro queda ligado a la misma
  referencia del argumento, de modo que una escritura dentro del
  procedimiento se observa fuera. Contrastar con el paso por valor
  sobre el mismo programa.
- **Solidez de un chequeador de tipos**: si $\Gamma \vdash e : t$ y el
  ambiente de valores $\rho$ concuerda con el ambiente de tipos
  $\Gamma$, entonces $\text{value-of}(e, \rho)$ es un valor de tipo
  $t$. Precisar primero qué significa la concordancia entre $\rho$ y
  $\Gamma$.

Cada propiedad debe enunciarse formalmente y demostrarse con el
mismo rigor que las funciones anteriores.

---

## 4. Referencias

- Friedman, D. P., & Wand, M. *Essentials of Programming Languages*,
  3.ª ed., MIT Press, 2008. Secciones 3.2(ASTs), 3.3(procedimientos y clausuras) y 3.4(ambientes y recursion).

