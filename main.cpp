#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

using namespace std;

// ===== ESTRUCTURAS =====
struct Curso {
  string codigo, nombre, area;
  int creditos;
};
struct Prerrequisito {
  string curso, prerrequisito;
};
struct Historial {
  string estudiante, codigoCurso;
  int nota;
};
struct Interes {
  string estudiante, area;
};

// ===== DATOS GLOBALES =====
vector<Curso> cursos;
vector<Prerrequisito> prerrequisitos;
vector<Historial> historiales;
vector<Interes> intereses;

// ===== CARGA INICIAL =====
void cargarDatosIniciales() {
  cursos = {{"CS101", "Programacion I", "Programacion", 4},
            {"CS102", "Programacion II", "Programacion", 4},
            {"BD101", "Base de Datos I", "Datos", 4},
            {"BD102", "Base de Datos II", "Datos", 4},
            {"IA101", "Inteligencia Artificial", "IA", 4},
            {"IA102", "Machine Learning", "IA", 4},
            {"MAT101", "Matematica Discreta", "Matematica", 3},
            {"RED101", "Redes de Computadoras", "Redes", 4}};
  prerrequisitos = {{"CS102", "CS101"}, {"BD101", "CS102"},
                    {"BD102", "BD101"}, {"IA101", "CS102"},
                    {"IA102", "IA101"}, {"RED101", "CS101"}};
  historiales = {{"estudiante1", "CS101", 15}, {"estudiante1", "CS102", 12},
                 {"estudiante1", "BD101", 9},  {"estudiante1", "MAT101", 14},
                 {"estudiante2", "CS101", 10}, {"estudiante2", "MAT101", 16},
                 {"estudiante2", "BD101", 8},  {"estudiante2", "RED101", 13}};
  intereses = {{"estudiante1", "Programacion"},
               {"estudiante1", "IA"},
               {"estudiante1", "Datos"},
               {"estudiante2", "Redes"}};
}

// ===== UTILIDAD =====
string buscarNombreCurso(const string &codigo) {
  for (const Curso &c : cursos)
    if (c.codigo == codigo)
      return c.nombre;
  return "Curso no encontrado";
}

// ===== REGISTRO DE DATOS =====
void registrarCurso() {
  Curso c;
  cout << "\nCodigo: ";
  cin >> c.codigo;
  cin.ignore();
  cout << "Nombre: ";
  getline(cin, c.nombre);
  cout << "Area: ";
  getline(cin, c.area);
  cout << "Creditos: ";
  cin >> c.creditos;
  cursos.push_back(c);
  cout << "\nCurso registrado.\n";
}

void registrarPrerrequisito() {
  Prerrequisito p;
  cout << "\nCodigo del curso: ";
  cin >> p.curso;
  cout << "Codigo del prerrequisito: ";
  cin >> p.prerrequisito;
  prerrequisitos.push_back(p);
  cout << "\nPrerrequisito registrado.\n";
}

void registrarNota() {
  Historial h;
  cout << "\nID estudiante: ";
  cin >> h.estudiante;
  cout << "Codigo del curso: ";
  cin >> h.codigoCurso;
  cout << "Nota obtenida: ";
  cin >> h.nota;
  historiales.push_back(h);
  cout << "\nNota registrada.\n";
}

void registrarInteres() {
  Interes i;
  cout << "\nID estudiante: ";
  cin >> i.estudiante;
  cin.ignore();
  cout << "Area de interes: ";
  getline(cin, i.area);
  intereses.push_back(i);
  cout << "\nInteres registrado.\n";
}

// ===== GENERACION DE CSV =====
void generarTodosLosCSV() {
  // cursos.csv
  ofstream fc("cursos.csv");
  fc << "codigo,nombre,area,creditos\n";
  for (const Curso &c : cursos)
    fc << c.codigo << "," << c.nombre << "," << c.area << "," << c.creditos
       << "\n";

  // prerrequisitos.csv
  ofstream fp("prerrequisitos.csv");
  fp << "curso,prerrequisito\n";
  for (const Prerrequisito &p : prerrequisitos)
    fp << p.curso << "," << p.prerrequisito << "\n";

  // historial.csv
  ofstream fh("historial.csv");
  fh << "estudiante,codigoCurso,nota\n";
  for (const Historial &h : historiales)
    fh << h.estudiante << "," << h.codigoCurso << "," << h.nota << "\n";

  // intereses.csv
  ofstream fi("intereses.csv");
  fi << "estudiante,area\n";
  for (const Interes &i : intereses)
    fi << i.estudiante << "," << i.area << "\n";

  cout << "\nArchivos CSV generados correctamente.\n";
}

// ===== CONSULTAS =====
void mostrarEstudiantes() {
  cout << "\n===== ESTUDIANTES REGISTRADOS =====\n";
  vector<string> vistos;
  int n = 0;
  for (const Historial &h : historiales) {
    bool existe = false;
    for (const string &id : vistos)
      if (id == h.estudiante) {
        existe = true;
        break;
      }
    if (!existe) {
      cout << ++n << ". " << h.estudiante << "\n";
      vistos.push_back(h.estudiante);
    }
  }
  cout << "Total: " << n << "\n";
}

void mostrarCursos() {
  cout << "\n===== CURSOS REGISTRADOS =====\n";
  for (const Curso &c : cursos)
    cout << c.codigo << " | " << c.nombre << " | " << c.area << " | "
         << c.creditos << " creditos\n";
  cout << "Total: " << cursos.size() << "\n";
}

// Funcion unificada para historial, aprobados y desaprobados
// filtro: 0=todos, 1=aprobados, -1=desaprobados
void mostrarHistorial(int filtro) {
  string est;
  bool encontrado = false;
  cout << "\nIngrese ID del estudiante: ";
  cin >> est;

  if (filtro == 1)
    cout << "\n===== CURSOS APROBADOS =====\n";
  else if (filtro == -1)
    cout << "\n===== CURSOS DESAPROBADOS =====\n";
  else
    cout << "\n===== HISTORIAL DE " << est << " =====\n";

  for (const Historial &h : historiales) {
    if (h.estudiante != est)
      continue;
    if (filtro == 1 && h.nota < 11)
      continue;
    if (filtro == -1 && h.nota >= 11)
      continue;
    cout << h.codigoCurso << " - " << buscarNombreCurso(h.codigoCurso)
         << " | Nota: " << h.nota << "\n";
    encontrado = true;
  }
  if (!encontrado)
    cout << "Sin registros para mostrar.\n";
}

void reporteGeneral() {
  string est;
  int suma = 0, total = 0, aprobados = 0, desaprobados = 0;
  int mayorNota = -1, menorNota = 21;
  string cursoMayor, cursoMenor;

  cout << "\nIngrese ID del estudiante: ";
  cin >> est;

  for (const Historial &h : historiales) {
    if (h.estudiante != est)
      continue;
    suma += h.nota;
    total++;
    h.nota >= 11 ? aprobados++ : desaprobados++;
    if (h.nota > mayorNota) {
      mayorNota = h.nota;
      cursoMayor = h.codigoCurso;
    }
    if (h.nota < menorNota) {
      menorNota = h.nota;
      cursoMenor = h.codigoCurso;
    }
  }

  if (total == 0) {
    cout << "\nEstudiante no encontrado.\n";
    return;
  }

  cout << "\n===== REPORTE GENERAL =====\n"
       << "Estudiante: " << est << "\n"
       << fixed << setprecision(2) << "Promedio: " << (double)suma / total
       << "\n"
       << "Aprobados: " << aprobados << "\n"
       << "Desaprobados: " << desaprobados << "\n"
       << "Mayor nota: " << buscarNombreCurso(cursoMayor) << " (" << mayorNota
       << ")\n"
       << "Menor nota: " << buscarNombreCurso(cursoMenor) << " (" << menorNota
       << ")\n";
}

// ===== MENU =====
void menu() {
  int op;
  do {
    cout << "\n=====================================\n"
         << " SISTEMA DE RECOMENDACION ACADEMICA\n"
         << " MODULO C++ - PARADIGMA IMPERATIVO\n"
         << "=====================================\n"
         << "1. Registrar curso\n"
         << "2. Registrar prerrequisito\n"
         << "3. Registrar nota de estudiante\n"
         << "4. Registrar area de interes\n"
         << "5. Mostrar estudiantes registrados\n"
         << "6. Mostrar cursos registrados\n"
         << "7. Mostrar historial de estudiante\n"
         << "8. Mostrar cursos aprobados\n"
         << "9. Mostrar cursos desaprobados\n"
         << "10. Mostrar reporte general\n"
         << "11. Generar archivos CSV\n"
         << "0. Salir\n"
         << "Seleccione una opcion: ";
    cin >> op;

    switch (op) {
    case 1:
      registrarCurso();
      break;
    case 2:
      registrarPrerrequisito();
      break;
    case 3:
      registrarNota();
      break;
    case 4:
      registrarInteres();
      break;
    case 5:
      mostrarEstudiantes();
      break;
    case 6:
      mostrarCursos();
      break;
    case 7:
      mostrarHistorial(0);
      break;
    case 8:
      mostrarHistorial(1);
      break;
    case 9:
      mostrarHistorial(-1);
      break;
    case 10:
      reporteGeneral();
      break;
    case 11:
      generarTodosLosCSV();
      break;
    case 0:
      generarTodosLosCSV();
      cout << "\nSaliendo...\n";
      break;
    default:
      cout << "\nOpcion invalida.\n";
    }
  } while (op != 0);
}

// ===== MAIN =====
int main() {
  cargarDatosIniciales(); // 1ro: cargar datos
  menu();                 // 2do: mostrar menu
  return 0;
}