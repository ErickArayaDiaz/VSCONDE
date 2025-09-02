// ======================
// Inicialización de filas con contador
// ======================
function inicializarFila(fila, tiempoId) {
  const botones = Array.from(fila.children);
  const ordenCorrecto = botones.map(b => b.textContent);

  let tiempo = 0;
  let intervalo = null;
  let nivelCompletado = false; // 🚩 para detener solo una vez
  const tiempoElemento = document.getElementById(tiempoId);

  const iniciarTiempo = () => {
    if (!intervalo && !nivelCompletado) {
      intervalo = setInterval(() => {
        tiempo++;
        tiempoElemento.textContent = `⏱ Tiempo: ${tiempo} s`;
      }, 1000);
    }
  };

  const detenerTiempo = () => {
    clearInterval(intervalo);
    intervalo = null;
  };

  const reiniciarTiempo = () => {
    detenerTiempo();
    tiempo = 0;
    nivelCompletado = false;
    tiempoElemento.classList.remove("completado");
    tiempoElemento.textContent = `⏱ Tiempo: 0 s`;
  };

  const verificarCorrectos = () => {
    const actuales = Array.from(fila.children);
    let todosCorrectos = true;

    actuales.forEach((btn, i) => {
      if (btn.textContent === ordenCorrecto[i]) {
        btn.disabled = true;
        btn.classList.add("correcto");
      } else {
        btn.disabled = false;
        btn.classList.remove("correcto");
        todosCorrectos = false;
      }
    });

    // ✅ detener cuando todo está correcto (solo primera vez)
    if (todosCorrectos && !nivelCompletado) {
      nivelCompletado = true;
      detenerTiempo();
      tiempoElemento.classList.add("completado");
      tiempoElemento.textContent += " ✅ ¡Nivel completado!";
    }
  };

  const mezclarFila = () => {
    const actuales = Array.from(fila.children);
    for (let i = actuales.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [actuales[i], actuales[j]] = [actuales[j], actuales[i]];
    }
    actuales.forEach(btn => fila.appendChild(btn));
    verificarCorrectos();
    reiniciarTiempo(); // 🔄 reset reinicia tiempo
  };

  const mezclarIncorrectos = () => {
    const actuales = Array.from(fila.children);
    const noCorrectos = actuales.filter((btn, i) => btn.textContent !== ordenCorrecto[i]);

    for (let i = noCorrectos.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [noCorrectos[i], noCorrectos[j]] = [noCorrectos[j], noCorrectos[i]];
    }

    let index = 0;
    actuales.forEach((btn, i) => {
      if (btn.textContent !== ordenCorrecto[i]) {
        fila.insertBefore(noCorrectos[index], fila.children[i]);
        index++;
      }
    });

    verificarCorrectos();
  };

  // ✅ Mezclamos todo al inicio
  mezclarFila();

  // Drag & Drop con SortableJS
  Sortable.create(fila, {
    animation: 150,
    onEnd: () => {
      iniciarTiempo(); // ⏱ empieza en primer movimiento
      verificarCorrectos();
      setTimeout(mezclarIncorrectos, 500);
    }
  });

  return { mezclarFila, reiniciarTiempo };
}

// ======================
// Manejo de filas
// ======================
const filas = document.querySelectorAll('.fila');
const manejadores = {};

filas.forEach(fila => {
  const filaClass = fila.classList[1];
  const tiempoId = filaClass.replace("fila", "tiempo");
  manejadores[filaClass] = inicializarFila(fila, tiempoId);
});

// Botones reset
document.querySelectorAll('.reset').forEach(btn => {
  btn.addEventListener("click", () => {
    const filaClass = btn.getAttribute("data-fila");
    manejadores[filaClass].mezclarFila();
    manejadores[filaClass].reiniciarTiempo();
  });
});

// ======================
// Navegación de pantallas
// ======================
let pantallaActual = 0;
const pantallas = document.querySelectorAll(".pantalla");

function mostrarPantalla(index) {
  pantallas.forEach((p, i) => p.classList.toggle("activa", i === index));
  pantallaActual = index;
}

document.querySelectorAll(".next").forEach(btn => {
  btn.addEventListener("click", () => {
    if (pantallaActual < pantallas.length - 1) {
      mostrarPantalla(pantallaActual + 1);
    }
  });
});

document.querySelectorAll(".prev").forEach(btn => {
  btn.addEventListener("click", () => {
    if (pantallaActual > 0) {
      mostrarPantalla(pantallaActual - 1);
    }
  });
});

// ======================
// Cambio automático de paletas
// ======================
const paletas = [
  ["#DBB3B1", "#C89FA3", "#A67F8E", "#6C534E", "#2C1A1D"], 
  ["#E66C53", "#E58653", "#E6B89F", "#E6A053"],            
  ["#04080F", "#507DBC", "#A1C6EA", "#BBD1EA", "#DAE3E5"], 
  ["#D2F1E4", "#FBCAEF", "#F865B0"],                      
  ["#E6D350", "#E6E551", "#A7E650", "#E6C150", "#69E650"]  
];

function aplicarPaleta(paleta) {
  const bodyBg = document.body;
  const overlay = bodyBg.querySelector("::before"); // no se puede acceder directo a ::before
  // 👉 mejor: aplicamos al body un estilo dinámico con variable CSS

  document.body.style.setProperty(
    "--paleta-actual",
    `linear-gradient(to right, ${paleta.join(", ")})`
  );

  // Forzamos animación usando una capa extra
  const fadeLayer = document.createElement("div");
  fadeLayer.style.position = "fixed";
  fadeLayer.style.top = "0";
  fadeLayer.style.left = "0";
  fadeLayer.style.width = "100%";
  fadeLayer.style.height = "100%";
  fadeLayer.style.zIndex = "-1";
  fadeLayer.style.background = `linear-gradient(to right, ${paleta.join(", ")})`;
  fadeLayer.style.opacity = "0";
  fadeLayer.style.transition = "opacity 2s ease";

  document.body.appendChild(fadeLayer);

  // Forzamos fade-in
  requestAnimationFrame(() => {
    fadeLayer.style.opacity = "1";
  });

  // Quitamos la capa anterior después de la animación
  setTimeout(() => {
    const oldLayers = document.querySelectorAll(".fade-layer");
    oldLayers.forEach((l, i) => {
      if (i < oldLayers.length - 1) l.remove();
    });
  }, 2500);
}


function cambiarFondoAleatorio() {
  const indice = Math.floor(Math.random() * paletas.length);
  aplicarPaleta(paletas[indice]);
}

setInterval(cambiarFondoAleatorio, 6000);
cambiarFondoAleatorio();
