﻿unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Math;

type
  { Клас для обчислення ряду Фур’є }
  TFourierCalculator = class
  private
    FNe, FNg: Integer;           // кількість точок табуляції та гармонік
    Fal, Fbl: Double;            // початок і кінець інтервалу
    FFunctionType: string;       // тип функції ('sin(x)', 'cos(x)', 'sin(x)*cos(x)+1')
    FXe, FYe, FYg: TArray<Double>; // табульовані значення x, значення функції та побудований ряд Фур’є
    Fa, Fb, Fc: TArray<Double>;  // коефіцієнти Фур’є та їх амплітуди
    // Обчислення значення функції залежно від типу
    function f(x: Double): Double;
  public
    constructor Create(a, b: Double; Ne, Ng: Integer; const FunctionType: string);
    // Табуляція функції f на проміжку [Fal, Fbl]
    procedure TabulateFunction;
    // Обчислення коефіцієнтів Фур’є та побудова ряду
    procedure ComputeFourier;
    // Візуалізація амплітуд гармонік на заданій канві
    procedure DrawHarmonics(Canvas: TCanvas; ImageWidth, ImageHeight: Integer; LineWidth: Integer);
    // Доступ до даних табуляції та обчислень
    property Xe: TArray<Double> read FXe;
    property Ye: TArray<Double> read FYe;
    property Yg: TArray<Double> read FYg;
    property A: TArray<Double> read Fa;
    property B: TArray<Double> read Fb;
    property C: TArray<Double> read Fc;
    property PointsCount: Integer read FNe;
    property HarmonicsCount: Integer read FNg;
  end;

  { Перерахування для методів інтегрування }
  TIntegrationMethod = (imMidpoint, imSimpson, imTrapezoid);

  { Клас для інтегрування з використанням різних методів }
  TIntegrator = class
  public
    // f – функція, яку інтегруємо; N – початкова кількість розбиттів
    class function Integrate(Method: TIntegrationMethod; a, b, eps: Double; var N: Integer; f: TFunc<Double, Double>): Double;
  end;

  TForm2 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    LabelResult: TLabel;
    Edital: TEdit;
    Editbl: TEdit;
    EditNg: TEdit;
    EditNe: TEdit;
    Button1: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    RadioGroup3: TRadioGroup;
    Image1: TImage;
    EditEps: TEdit;
    Label11: TLabel;
    EditN: TEdit;
    Label12: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

{=========================== TFourierCalculator ===========================}

constructor TFourierCalculator.Create(a, b: Double; Ne, Ng: Integer; const FunctionType: string);
begin
  Fal := a;
  Fbl := b;
  FNe := Ne;
  FNg := Ng;
  FFunctionType := FunctionType;
  SetLength(FXe, FNe + 1);
  SetLength(FYe, FNe + 1);
  SetLength(FYg, FNe + 1);
  SetLength(Fa, FNg + 1);
  SetLength(Fb, FNg + 1);
  SetLength(Fc, FNg + 1);
end;

// Функція f(x) залежно від вибраного типу
function TFourierCalculator.f(x: Double): Double;
begin
  if FFunctionType = 'sin(x)' then
    Result := sin(x)
  else if FFunctionType = 'cos(x)' then
    Result := cos(x)
  else if FFunctionType = 'sin(x)*cos(x)+1' then
    Result := sin(x) * cos(x) + 1
  else
    Result := sin(x);  // За замовчуванням
end;

// Табуляція функції f на проміжку [Fal, Fbl]
procedure TFourierCalculator.TabulateFunction;
var
  h: Double;
  i: Integer;
begin
  h := (Fbl - Fal) / FNe;
  FXe[0] := Fal;
  for i := 0 to FNe - 1 do
  begin
    FYe[i] := f(FXe[i]);
    FXe[i + 1] := FXe[i] + h;
  end;
  FYe[FNe] := f(FXe[FNe]); // Обчислення останнього значення
end;

// Обчислення коефіцієнтів Фур’є та побудова ряду Фур’є
procedure TFourierCalculator.ComputeFourier;
var
  i, k: Integer;
  Tp, w, S, D, KOM: Double;
begin
  Tp := Fbl - Fal;
  w := 2 * Pi / Tp;
  // Обчислення коефіцієнтів a[k] та b[k] для k = 1 до FNg
  for k := 1 to FNg do
  begin
    S := 0.0;
    D := 0.0;
    for i := 0 to FNe do
    begin
      KOM := k * w * FXe[i];
      S := S + FYe[i] * cos(KOM);
      D := D + FYe[i] * sin(KOM);
    end;
    Fa[k] := 2 * S / (FNe + 1);
    Fb[k] := 2 * D / (FNe + 1);
    Fc[k] := Sqrt(Sqr(Fa[k]) + Sqr(Fb[k]));
  end;
  // Обчислення a[0] як середнього значення
  Fa[0] := 0.0;
  for i := 0 to FNe do
    Fa[0] := Fa[0] + FYe[i];
  Fa[0] := Fa[0] / (FNe + 1);
  // Побудова ряду Фур’є через x
  for i := 0 to FNe do
  begin
    S := 0.0;
    for k := 1 to FNg do
    begin
      KOM := k * w * FXe[i];
      S := S + Fa[k] * cos(KOM) + Fb[k] * sin(KOM);
    end;
    FYg[i] := Fa[0] + S;
  end;
end;

// Візуалізація амплітуд гармонік на канвасі
procedure TFourierCalculator.DrawHarmonics(Canvas: TCanvas; ImageWidth, ImageHeight: Integer; LineWidth: Integer);
var
  i, krokx: Integer;
  MaxC, ky, w: Real;
  x: Integer;
begin
  krokx := (ImageWidth - 40) div FNg;
  MaxC := Fc[1];
  for i := 2 to FNg do
    if Fc[i] > MaxC then
      MaxC := Fc[i];
  if MaxC = 0 then
    MaxC := 1; // Щоб не ділити на 0
  ky := (ImageHeight div 2) / MaxC;
  with Canvas do
  begin
    Pen.Color := clHighlight;
    Pen.Width := 2;
    // Малювання осей
    MoveTo(20, 40);
    LineTo(30, 30);
    LineTo(40, 40);
    MoveTo(30, 30);
    LineTo(30, ImageHeight - 50);
    LineTo(ImageWidth - 20, ImageHeight - 50);
    MoveTo(ImageWidth - 40, ImageHeight - 60);
    LineTo(ImageWidth - 20, ImageHeight - 50);
    LineTo(ImageWidth - 40, ImageHeight - 40);
    TextOut(18, 20, 'C');
    TextOut(ImageWidth - 50, ImageHeight - 25, 'W');
    Pen.Color := clLime;
    Pen.Width := 2;
    x := krokx + 20;
    w := 2 * Pi / (Fbl - Fal);
    for i := 1 to FNg do
    begin
      MoveTo(Round(x) + 3, ImageHeight - 50);
      LineTo(Round(x) + 3, ImageHeight - 50 - Round(ky * Fc[i]));
      TextOut(Round(x), ImageHeight - Round(ky * Fc[i]) - 65,
        FloatToStrF(Fc[i], ffGeneral, 0, 0));
      Ellipse(Round(x), ImageHeight - 53, Round(x) + 5, ImageHeight - 48);
      Ellipse(Round(x) + 1, ImageHeight - 50 - Round(ky * Fc[i]),
        Round(x) + 7, ImageHeight - 50 - Round(ky * Fc[i]) + 5);
      x := x + krokx;
    end;
    x := krokx + 19;
    TextOut(Round(x), ImageHeight - 30,
      'W=' + FloatToStrF(w, ffGeneral, 0, 0));
  end;
end;

{============================= TIntegrator ================================}

class function TIntegrator.Integrate(Method: TIntegrationMethod; a, b, eps: Double; var N: Integer; f: TFunc<Double, Double>): Double;
var
  steps: Integer;
  prevResult, resultValue, h, sum, x, fa, fb: Double;
  i: Integer;
  sumOdd, sumEven: Double;
begin
  steps := 0;
  prevResult := Infinity;
  resultValue := 0.0;
  case Method of
    imMidpoint:
      begin
        while True do
        begin
          h := (b - a) / N;
          sum := 0.0;
          for i := 1 to N do
          begin
            x := a + h * (i - 0.5);
            sum := sum + f(x);
          end;
          resultValue := h * sum;
          Inc(steps);
          if Abs(resultValue - prevResult) < eps then
            Break;
          prevResult := resultValue;
          N := N * 2;
        end;
      end;
    imTrapezoid:
      begin
        while True do
        begin
          h := (b - a) / N;
          sum := 0.0;
          for i := 1 to N - 1 do
          begin
            x := a + i * h;
            sum := sum + f(x);
          end;
          fa := f(a);
          fb := f(b);
          resultValue := h * (fa + fb + 2 * sum) / 2.0;
          Inc(steps);
          if Abs(resultValue - prevResult) < eps then
            Break;
          prevResult := resultValue;
          N := N * 2;
        end;
      end;
    imSimpson:
      begin
        while True do
        begin
          if (N mod 2) <> 0 then
            N := N + 1;
          h := (b - a) / N;
          sumOdd := 0.0;
          sumEven := 0.0;
          for i := 1 to N - 1 do
          begin
            x := a + i * h;
            if (i mod 2) = 1 then
              sumOdd := sumOdd + f(x)
            else
              sumEven := sumEven + f(x);
          end;
          fa := f(a);
          fb := f(b);
          resultValue := h * (fa + fb + 4 * sumOdd + 2 * sumEven) / 6.0;
          Inc(steps);
          if Abs(resultValue - prevResult) < eps then
            Break;
          prevResult := resultValue;
          N := N * 2;
        end;
      end;
  end;
  Result := resultValue;
end;

{============================= TForm2 =====================================}

procedure TForm2.Button1Click(Sender: TObject);
var
  FourierCalc: TFourierCalculator;
  i: Integer;
  minYg, maxYg, minx, maxx, miny, maxy, kx, ky: Real;
  ox, oy, krokx, kroky: Integer;
begin
  // Перевірка коректності введених даних для табуляції та ряду Фур’є
  try
    FourierCalc := TFourierCalculator.Create(StrToFloat(Edital.Text), StrToFloat(Editbl.Text),
      StrToInt(EditNe.Text), StrToInt(EditNg.Text), ComboBox5.Text);
  except
    on E: Exception do
    begin
      ShowMessage('Введіть правильні значення для Ne, al та bl.');
      Exit;
    end;
  end;

  try
    // Табуляція функції та обчислення ряду Фур’є
    FourierCalc.TabulateFunction;
    FourierCalc.ComputeFourier;

    // Визначення мінімальних та максимальних значень для масштабування графіка
    minYg := FourierCalc.Yg[0];
    maxYg := FourierCalc.Yg[0];
    for i := 1 to FourierCalc.PointsCount do
    begin
      if FourierCalc.Yg[i] > maxYg then maxYg := FourierCalc.Yg[i];
      if FourierCalc.Yg[i] < minYg then minYg := FourierCalc.Yg[i];
    end;

    minx := FourierCalc.Xe[0];
    maxx := FourierCalc.Xe[FourierCalc.PointsCount];
    miny := FourierCalc.Ye[0];
    maxy := FourierCalc.Ye[0];

    for i := 1 to FourierCalc.PointsCount do
    begin
      if FourierCalc.Ye[i] > maxy then maxy := FourierCalc.Ye[i];
      if FourierCalc.Ye[i] < miny then miny := FourierCalc.Ye[i];
    end;

    if maxy < maxYg then maxy := maxYg;
    if miny > minYg then miny := minYg;

    // Розрахунок коефіцієнтів масштабування
    kx := (Image1.Width - 40) / (maxx - minx);
    ky := (Image1.Height - 40) / (maxy - miny);

    // Розрахунок зміщення для осей (якщо 0 знаходиться всередині інтервалу)
    if (minx < 0) and (maxx > 0) then
      ox := 20 + Round((0 - minx) * kx)
    else if maxx <= 0 then
      ox := 20 + Round((maxx - minx) * kx)
    else
      ox := 20;

    if (miny < 0) and (maxy > 0) then
      oy := Image1.Height - 20 - Round((0 - miny) * ky)
    else if maxy <= 0 then
      oy := Image1.Height - 20 - Round((maxy - miny) * ky)
    else
      oy := Image1.Height - 20;

    // Малювання сітки та графіків на канві
    with Image1 do
    begin
      // Очищення полотна
      Canvas.Brush.Color := clWhite;
      Canvas.FillRect(Rect(0, 0, Width, Height));
      Canvas.Pen.Width := 2;
      Canvas.Pen.Color := clPurple;
      Canvas.Rectangle(1, 1, Width - 1, Height - 1);

      Canvas.Pen.Color := clSilver;
      Canvas.Pen.Width := StrToInt(ComboBox4.Text);
      krokx := (Width - 40) div 10;
      kroky := (Height - 40) div 10;
      for i := 0 to 10 do
      begin
        Canvas.MoveTo(20, 20 + i * kroky);
        Canvas.LineTo(Width - 20, 20 + i * kroky);
        Canvas.MoveTo(20 + i * krokx, 20);
        Canvas.LineTo(20 + i * krokx, Height - 20);
      end;

      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Width := StrToInt(ComboBox3.Text);
      Canvas.MoveTo(20, oy);
      Canvas.LineTo(Width - 20, oy);
      Canvas.MoveTo(ox, 20);
      Canvas.LineTo(ox, Height - 20);

      // Малювання графіка початкової функції (Ye)
      Canvas.Pen.Color := clRed;
      Canvas.Pen.Width := StrToInt(ComboBox2.Text);
      Canvas.MoveTo(20 + Round((FourierCalc.Xe[0] - minx) * kx), Height - 20 - Round((FourierCalc.Ye[0] - miny) * ky));
      for i := 1 to FourierCalc.PointsCount do
        Canvas.LineTo(20 + Round((FourierCalc.Xe[i] - minx) * kx),
                      Height - 20 - Round((FourierCalc.Ye[i] - miny) * ky));

      // Малювання ряду Фур’є (Yg)
      Canvas.Pen.Color := clLime;
      Canvas.Pen.Width := StrToInt(ComboBox1.Text);
      Canvas.MoveTo(20 + Round((FourierCalc.Xe[0] - minx) * kx), Height - 20 - Round((FourierCalc.Yg[0] - miny) * ky));
      for i := 1 to FourierCalc.PointsCount do
        Canvas.LineTo(20 + Round((FourierCalc.Xe[i] - minx) * kx),
                      Height - 20 - Round((FourierCalc.Yg[i] - miny) * ky));
    end;

    // Якщо користувач хоче побачити гармоніки, викликаємо метод DrawHarmonics
    if MessageDlg('Гармоніки?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Image1.Picture := nil;
      FourierCalc.DrawHarmonics(Image1.Canvas, Image1.Width, Image1.Height, StrToInt(ComboBox4.Text));
    end;
  finally
    FourierCalc.Free;
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  aVal, bVal, eps: Double;
  n: Integer;
  integralResult: Double;
begin
  try
    aVal := StrToFloat(Edital.Text);
    bVal := StrToFloat(Editbl.Text);
    n := StrToInt(EditN.Text);
    eps := StrToFloat(EditEps.Text);
  except
    on E: Exception do
    begin
      ShowMessage('Невірне значення параметрів інтегрування.');
      Exit;
    end;
  end;

  // Використовуємо відповідний метод інтегрування, передаючи функцію f(x) залежно від вибору
  case RadioGroup3.ItemIndex of
    0: integralResult := TIntegrator.Integrate(imMidpoint, aVal, bVal, eps, n,
                function(x: Double): Double
                begin
                  if ComboBox5.Text = 'sin(x)' then
                    Result := sin(x)
                  else if ComboBox5.Text = 'cos(x)' then
                    Result := cos(x)
                  else if ComboBox5.Text = 'sin(x)*cos(x)+1' then
                    Result := sin(x) * cos(x) + 1
                  else
                    Result := sin(x);
                end);
    1: integralResult := TIntegrator.Integrate(imSimpson, aVal, bVal, eps, n,
                function(x: Double): Double
                begin
                  if ComboBox5.Text = 'sin(x)' then
                    Result := sin(x)
                  else if ComboBox5.Text = 'cos(x)' then
                    Result := cos(x)
                  else if ComboBox5.Text = 'sin(x)*cos(x)+1' then
                    Result := sin(x) * cos(x) + 1
                  else
                    Result := sin(x);
                end);
    2: integralResult := TIntegrator.Integrate(imTrapezoid, aVal, bVal, eps, n,
                function(x: Double): Double
                begin
                  if ComboBox5.Text = 'sin(x)' then
                    Result := sin(x)
                  else if ComboBox5.Text = 'cos(x)' then
                    Result := cos(x)
                  else if ComboBox5.Text = 'sin(x)*cos(x)+1' then
                    Result := sin(x) * cos(x) + 1
                  else
                    Result := sin(x);
                end);
  else
    integralResult := TIntegrator.Integrate(imMidpoint, aVal, bVal, eps, n,
                function(x: Double): Double
                begin
                  if ComboBox5.Text = 'sin(x)' then
                    Result := sin(x)
                  else if ComboBox5.Text = 'cos(x)' then
                    Result := cos(x)
                  else if ComboBox5.Text = 'sin(x)*cos(x)+1' then
                    Result := sin(x) * cos(x) + 1
                  else
                    Result := sin(x);
                end);
  end;

  LabelResult.Caption := 'Інтеграл = ' + FloatToStr(integralResult) + ' N = ' + IntToStr(n);
  LabelResult.Refresh;
end;

end.

